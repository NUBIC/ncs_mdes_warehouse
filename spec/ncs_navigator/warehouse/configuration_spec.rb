require 'spec_helper'

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

    describe 'add_post_etl_hook' do
      let(:success_hook) {
        Object.new.tap do |o|
          class << o
            def etl_succeeded; end
          end
        end
      }

      let(:failure_hook) {
        Object.new.tap do |o|
          class << o
            def etl_failed; end
          end
        end
      }

      it 'adds a hook with an `etl_succeeded` method' do
        config.add_post_etl_hook(success_hook)
        config.post_etl_hooks.should == [success_hook]
      end

      it 'adds a hook with an `etl_failed` method' do
        config.add_post_etl_hook(failure_hook)
        config.post_etl_hooks.should == [failure_hook]
      end

      describe 'with an object without either etl callback method' do
        it 'gives a helpful message if the object is constructable' do
          lambda { config.add_post_etl_hook(String) }.
            should raise_error('String does not have an etl_succeeded or etl_failed method. Perhaps you meant String.new?')
        end

        it 'gives a helpful message if the object is an instance' do
          lambda { config.add_post_etl_hook('not a good hook') }.
            should raise_error('"not a good hook" does not have an etl_succeeded or etl_failed method.')
        end

        it 'does not add the object as a hook' do
          begin
            config.add_post_etl_hook('not a good hook')
          rescue
          end
          config.post_etl_hooks.should be_empty
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

    describe '#mdes', :slow, :modifies_warehouse_state do
      it 'Uses the default MDES version if called before mdes_version=' do
        config.mdes.version.should == NcsNavigator::Warehouse::DEFAULT_MDES_VERSION
      end

      # see above for test of non-default value
    end

    describe '#models_module', :slow, :modifies_warehouse_state do
      it 'Uses the default MDES version if called before mdes_version=' do
        config.models_module.mdes_version.should == NcsNavigator::Warehouse::DEFAULT_MDES_VERSION
      end

      # see above for test of non-default value
    end

    describe '#model' do
      context 'for a known version', :slow, :use_mdes, :modifies_warehouse_state do
        describe 'by table name' do
          let(:actual) { config.model('link_contact') }

          it 'finds the model' do
            actual.to_s.should =~ /LinkContact$/
          end

          it 'returns a class' do
            actual.should be_a Class
          end

          it 'returns a class in the models module' do
            actual.to_s.should =~ %r[^#{config.models_module.to_s}]
          end

          it 'returns nil if no match' do
            config.model('quux').should be_nil
          end
        end

        describe 'by model name' do
          let(:actual) { config.model(:Person) }

          it 'finds the model' do
            actual.to_s.should =~ /Person$/
          end

          it 'returns a class' do
            actual.should be_a Class
          end

          it 'returns a class in the models module' do
            actual.to_s.should =~ %r[^#{config.models_module.to_s}]
          end

          it 'returns nil if no match' do
            config.model(:Foo).should be_nil
          end
        end
      end
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
        config.shell_io.object_id.should be($stderr.object_id)
        # `should be($stderr)` and `should equal($stderr)` do not work
        # with RSpec 2.10 and ci_reporter 1.6.6 because `should` is
        # apparently delegated to the wrapped stream.
      end

      it 'can be set' do
        expected = StringIO.new
        config.shell_io = expected
        config.shell_io.should be expected
      end
    end

    describe '#log_file', :modifies_warehouse_state do
      before do
        NcsNavigator::Warehouse.env = 'the_moon'
      end

      describe 'by default' do
        it 'is /var/log/nubic/ncs/warehouse/{env_name}.log' do
          config.log_file.to_s.should == '/var/log/nubic/ncs/warehouse/the_moon.log'
        end

        it 'is a Pathname' do
          config.log_file.should be_a(Pathname)
        end
      end

      describe 'when set' do
        describe 'to a String' do
          before do
            config.log_file = '/var/log/foo.log'
          end

          it 'takes the setting' do
            config.log_file.to_s.should == '/var/log/foo.log'
          end

          it 'is converted to a Pathname' do
            config.log_file.should be_a(Pathname)
          end
        end

        describe 'to nil' do
          before do
            config.log_file = nil
          end

          it 'reverts to the default' do
            config.log_file.to_s.should == '/var/log/nubic/ncs/warehouse/the_moon.log'
          end
        end

        describe 'to a Pathname' do
          let(:expected) { Pathname.new('/var/log/bar.log') }

          before do
            config.log_file = expected
          end

          it 'is the same Pathname' do
            config.log_file.should be(expected)
          end
        end
      end
    end

    describe '#log', :modifies_warehouse_state do
      before do
        config.log_file = tmpdir('logs') + 'test.log'
      end

      it 'sets up the log if not already set up' do
        config.log.should_not be_nil
      end
    end

    describe '#set_up_logs', :modifies_warehouse_state do
      before do
        NcsNavigator::Warehouse.env = 'development'
      end

      describe 'when the log can be written' do
        let(:file) { tmpdir('logs') + 'test.log' }

        before do
          config.log_file = file
          config.set_up_logs
        end

        it 'logs to a file in the configured directory' do
          config.log.error('Is this thing on?')

          file.read.should =~ /this thing/
        end

        it 'sets up the DataMapper log' do
          ::DataMapper.logger.info('DM did something')

          file.read.should =~ /DM did something/
        end
      end

      describe 'when the log cannot be written' do
        let(:out) { StringIO.new }

        before do
          @original_stdout, $stdout = $stdout, out
          config.log_file = '/made/up/does/not/exist.log'
          config.set_up_logs
        end

        after do
          $stdout = @original_stdout
        end

        it 'warns after setup' do
          out.string.should =~ %r{WARNING: Could not create or update log /made/up/does/not/exist.log.}
          out.string.should =~ %r{WARNING: Will log errors and warnings to standard out until this is fixed.}
        end

        it 'does not emit debug info to standard out' do
          config.log.debug('Hello?')
          out.string.should_not =~ /Hello/
        end

        it 'emits warnings to standard out' do
          config.log.warn("Don't press the red button")
          out.string.should =~ /red button/
        end

        it 'does not emit DataMapper debug messages to standard out' do
          ::DataMapper.logger.debug("Eleven!")
          out.string.should_not =~ /Eleven/
        end

        it 'emits DataMapper warnings to standard out' do
          ::DataMapper.logger.warn("You'll regret updating that")
          out.string.should =~ /regret/
        end
      end
    end

    describe '#set_up_action_mailer' do
      before do
        config.set_up_action_mailer
      end

      it 'sets the SMTP settings from navigator.ini' do
        ActionMailer::Base.smtp_settings[:address].should == 'smtp.ncs.gov'
      end

      it 'sets the delivery mode to SMTP' do
        ActionMailer::Base.delivery_method.should == :smtp
      end

      it 'sets the template path appropriately' do
        ActionMailer::Base.view_paths.collect(&:to_s).should == [
          File.expand_path('../../../../lib/ncs_navigator/warehouse/mailer_templates', __FILE__)
        ]
      end

      it 'only gets set up once' do
        ActionMailer::Base.delivery_method = :test
        config.set_up_action_mailer
        ActionMailer::Base.delivery_method.should == :test
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

    describe '#pg_bin_path' do
      it 'defaults to nil' do
        config.pg_bin_path.should be_nil
      end

      describe 'when set' do
        before do
          config.pg_bin_path = '/Library/PostgreSQL/9.0/bin'
        end

        it 'is retrievable' do
          config.pg_bin_path.to_s.should == '/Library/PostgreSQL/9.0/bin'
        end

        it 'becomes a Pathname' do
          config.pg_bin_path.should be_a Pathname
        end
      end
    end

    describe '#pg_bin' do
      describe 'with no path' do
        before do
          config.pg_bin_path = nil
        end

        it 'prepends nothing' do
          config.pg_bin('pg_dumpall').to_s.should == 'pg_dumpall'
        end
      end

      describe 'with a path' do
        before do
          config.pg_bin_path = '/home/me/bin'
        end

        it 'prepends the path' do
          config.pg_bin('pg_dumpall').to_s.should == '/home/me/bin/pg_dumpall'
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

      it 'evaluates constants from NcsNavigator::Warehouse::Transformers' do
        write_file do |f|
          f.puts 'c.log_file = "#{EnumTransformer}.log"'
        end

        subject.log_file.to_s.should == 'NcsNavigator::Warehouse::Transformers::EnumTransformer.log'
      end

      it 'reports missing constants as bare' do
        write_file do |f|
          f.puts 'c.add_transformer = ATransformerIForgotToRequire'
        end

        lambda { subject }.should raise_error(/uninitialized constant ATransformerIForgotToRequire/)
      end

      describe 'source file tracking' do
        it 'knows what file it came from' do
          write_file { }
          subject.configuration_file.to_s.should == filename.to_s
        end

        it 'resolves relative paths' do
          write_file { }
          FileUtils.cd tmpdir do
            Configuration.from_file('test.rb').configuration_file.to_s.should == filename.to_s
          end
        end

        it 'exposes the source file during evaluation' do
          write_file do |f|
            f.puts 'filename = c.configuration_file.to_s'
            f.puts 'c.add_transformer NcsNavigator::Warehouse::Transformers::SubprocessTransformer.new(c, ["foo", filename])'
          end
          subject.transformers.first.exec_and_args.should == ['foo', filename.to_s]
        end
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

    describe '.for_environment', :modifies_warehouse_state do
      include FakeFS::SpecHelpers

      before do
        # In FakeFS
        Pathname.new('/etc/nubic/ncs/warehouse').mkpath
      end

      it 'reads from the default path for the named environment' do
        File.open('/etc/nubic/ncs/warehouse/prod.rb', 'w') do |f|
          f.puts 'c.output_level = :quiet'
        end
        Configuration.for_environment('prod').output_level.should == :quiet
      end

      it 'defaults to the config for the current environment' do
        NcsNavigator::Warehouse.env = 'development'
        File.open('/etc/nubic/ncs/warehouse/development.rb', 'w') do |f|
          f.puts 'c.output_level = :quiet'
        end

        Configuration.for_environment.output_level.should == :quiet
      end

      it 'returns a blank configuration when the file is missing' do
        FakeFS.deactivate!

        Configuration.for_environment('made-up-one').output_level.should == :normal
      end
    end
  end
end
