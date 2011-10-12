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
  end
end
