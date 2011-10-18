require File.expand_path('../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse
  describe Configuration do
    let(:config) { Configuration.new }

    describe 'add_transformer' do
      let(:transformer) {
        Object.new.tap do |o|
          class << o
            def transform
              'transform called'
            end
          end
        end
      }

      it 'adds a valid transformer' do
        config.add_transformer transformer
        config.transformers.should == [transformer]
      end

      describe 'with an object without a #transform method' do
        it 'gives a helpful message if the object is constructable' do
          lambda { config.add_transformer(String) }.
            should raise_error('String does not have a transform method. Perhaps you meant String.new?')
        end

        it 'gives a helpful message if the object is just an instance' do
          lambda { config.add_transformer("not a transformer") }.
            should raise_error('"not a transformer" does not have a transform method.')
        end

        it 'does not add the transformer' do
          begin
            config.add_transformer('not a transformer')
          rescue
          end
          config.transformers.should be_empty
        end
      end
    end

    describe '#mdes_version=' do
      context 'for a known version', :slow, :use_mdes, :modifies_warehouse_state  do
        it 'makes the models available' do
          ::DataMapper::Model.descendants.
            collect { |m| m.name.demodulize }.should include('Address')
        end

        it 'makes the MDES specification available' do
          spec_config.mdes.version.should == spec_mdes_version
        end

        it 'makes the models module available' do
          spec_config.models_module.name.should =~ /^NcsNavigator::Warehouse::Models::\w+$/
        end
      end

      it 'throws an exception for an unknown version' do
        lambda { config.mdes_version = '42.42' }.
          should raise_error /No warehouse models exist for MDES version 42.42/
      end
    end

    describe '#mdes' do
      it 'throws an exception when called before mdes_version=' do
        lambda { config.mdes }.
          should raise_error(/Set an MDES version first/)
      end

      # see above for positive test
    end

    describe '#models_module' do
      it 'throws an exception when called before mdes_version=' do
        lambda { config.models_module }.
          should raise_error(/Set an MDES version first to load the models/)
      end

      # see above for positive test
    end

    describe '#navigator' do
      it 'defaults to the global default instance' do
        config.navigator.should be(NcsNavigator.configuration)
      end

      it 'can be overridden by setting a path' do
        config.navigator_ini = File.expand_path('../../../navigator.ini', __FILE__)
        config.navigator.should_not be(NcsNavigator.configuration)
        config.navigator.should_not be_nil
      end
    end

    describe '#output_level' do
      it 'defaults to :normal' do
        config.output_level.should == :normal
      end
    end

    describe '#output_level=' do
      it 'accepts :normal' do
        lambda { config.output_level = :normal }.should_not raise_error
      end

      it 'accepts :quiet' do
        lambda { config.output_level = :quiet }.should_not raise_error
      end

      it 'accepts a string instead of a symbol' do
        lambda { config.output_level = 'normal' }.should_not raise_error
      end

      it 'converts a string to a symbol' do
        config.output_level = 'quiet'
        config.output_level.should == :quiet
      end

      it 'rejects other values' do
        lambda { config.output_level = :noisy }.
          should raise_error(':noisy is not a valid value for output_level.')
      end
    end

    describe '#shell' do
      it 'is an updating shell by default' do
        config.shell.should be_a UpdatingShell
      end

      it 'uses the configured shell_io' do
        io = StringIO.new
        config.shell_io = io
        config.shell.say 'Hello'
        io.string.should == 'Hello'
      end

      it 'is a quiet shell with output level quiet' do
        config.output_level = :quiet
        config.shell.should be_a UpdatingShell::Quiet
      end
    end

    describe '#shell_io' do
      it 'is $stderr by default' do
        config.shell_io.should be(STDERR)
      end

      it 'can be set' do
        expected = StringIO.new
        config.shell_io = expected
        config.shell_io.should be expected
      end
    end

    describe 'bcdatabase' do
      describe 'group', :modifies_warehouse_state do
        subject { config.bcdatabase_group }

        [
          %w(local_postgresql development),
          %w(public_ci_postgresql9 ci),
          %w(ncsdb_staging staging),
          %w(ncsdb_prod production),
        ].collect { |exp, env| [exp.to_sym, env] }.each do |expected, environment|
          it "is #{expected} for #{environment}" do
            NcsNavigator::Warehouse.env = environment
            subject.should == expected
          end
        end

        it 'throws an exception for an unknown environment' do
          NcsNavigator::Warehouse.env = 'the_moon'
          lambda { subject }.should raise_error(/unknown environment the_moon/i)
        end

        it 'can be set manually' do
          config.bcdatabase_group = 'custom'
          subject.should == 'custom'
        end
      end

      describe 'entries' do
        describe ':working' do
          it 'defaults to :mdes_warehouse_working' do
            config.bcdatabase_entries[:working].should == :mdes_warehouse_working
          end
        end

        describe ':reporting' do
          it 'defaults to :mdes_warehouse_reporting' do
            config.bcdatabase_entries[:reporting].should == :mdes_warehouse_reporting
          end
        end

        it 'can be updated' do
          config.bcdatabase_entries[:working] = :custom_working
          config.bcdatabase_entries[:working].should == :custom_working
        end
      end
    end

    describe '.from_file' do
      let(:filename) { tmpdir + 'test.rb' }
      subject { Configuration.from_file(filename) }

      def write_file
        File.open(filename, 'w') do |f|
          yield f
        end
      end

      it 'exposes "c" as the configuration' do
        write_file do |f|
          f.puts 'c.output_level = :quiet'
        end
        subject.output_level.should == :quiet
      end

      it 'exposes "configuration" as the configuration' do
        write_file do |f|
          f.puts 'configuration.bcdatabase_group = :custom'
        end
        subject.bcdatabase_group.should == :custom
      end

      describe 'with errors' do
        before do
          write_file do |f|
            f.puts 'c.add_transformer "not a transformer"'
            f.puts '# another line'
            f.puts 'c.output_level = :noisy'
          end
        end

        it 'reports the first error' do
          lambda { subject }.should raise_error(/not a transformer/)
        end

        it 'reports the second error' do
          lambda { subject }.should raise_error(/:noisy/)
        end

        it 'includes the line numbers' do
          lambda { subject }.should raise_error(/line 3:.*?:noisy/)
        end
      end
    end

    describe '.for_environment' do
      it 'reads from the default path' do
        Configuration.should_receive(:from_file).with('/etc/nubic/ncs/warehouse/prod.rb')
        Configuration.for_environment('prod')
      end
    end
  end
end
