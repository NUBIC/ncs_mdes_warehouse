require File.expand_path('../../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::Transformers
  describe SubprocessTransformer do
    let(:script_name) { tmpdir + 'subprocess_test_script.sh' }
    let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only(script_name) }
    let(:config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |c|
        c.output_level = :quiet
        c.log_file = tmpdir + 'spec.log'
      end
    }
    let(:options) { { } }
    let(:messages) { transform_status.transform_errors.collect(&:message) }

    subject { SubprocessTransformer.new(config, ['bash', script_name.to_s], options) }

    def write_script
      File.open(script_name, 'w') do |f|
        yield f
      end
    end

    describe '#name' do
      it 'is the command line' do
        subject.name.should == "bash #{script_name}"
      end
    end

    describe '#transform' do
      let(:side_file) { tmpdir + 'quux.foo' }

      it 'executes the script' do
        write_script do |f|
          f.puts %(echo "bar" > '#{side_file}')
        end

        subject.transform(transform_status)

        side_file.read.should == "bar\n"
      end
    end

    describe 'status updating' do
      describe 'with JSON errors' do
        before do
          write_script do |f|
            f.puts %(echo '{ "message": "A bad bad thing" }')
            f.puts %(echo '{ "message": "A record-specific bad thing", "record_id": "foo11", "model_class": "Person" }')
            f.puts %(echo 93)
          end

          subject.transform(transform_status)
        end

        it 'appends the errors to the status' do
          transform_status.should have(2).transform_errors
        end

        it 'updates the record count from the last line' do
          transform_status.record_count.should == 93
        end

        describe 'error detail' do
          let(:error0) { transform_status.transform_errors[0] }
          let(:error1) { transform_status.transform_errors[1] }

          it 'includes the message' do
            error0.message.should == 'A bad bad thing'
          end

          it 'includes the record_id' do
            error1.record_id.should == 'foo11'
          end

          it 'includes the model class' do
            error1.model_class.should == 'Person'
          end
        end
      end

      describe 'with no errors' do
        before do
          write_script do |f|
            f.puts %(echo 77)
          end

          subject.transform(transform_status)
        end

        it 'updates the record count' do
          transform_status.record_count.should == 77
        end

        it 'has no errors' do
          transform_status.should have(0).transform_errors
        end
      end

      describe 'with no output' do
        before do
          write_script { }
          subject.transform(transform_status)
        end

        it 'has no records' do
          transform_status.record_count.should == 0
        end

        it 'has no errors' do
          transform_status.should have(0).transform_errors
        end
      end

      describe 'with non-JSON errors' do
        before do
          write_script do |f|
            f.puts %(echo 'A bad bad thing')
            f.puts %(echo 'Another bad thing')
            f.puts %(echo 90)
          end

          subject.transform(transform_status)
        end

        it 'has the errors' do
          messages.should == [
            "A bad bad thing", "Another bad thing"
          ]
        end

        it 'has the record count' do
          transform_status.record_count.should == 90
        end
      end

      describe 'with a nonzero exit' do
        before do
          write_script do |f|
            f.puts %(echo '{ "message": "A bad bad thing" }')
            f.puts %(echo 'Another bad thing')
            f.puts %(exit 4)
          end

          subject.transform(transform_status)
        end

        it 'has any errors that were printed before the exit' do
          messages[0..1].should == [
            "A bad bad thing", "Another bad thing"
          ]
        end

        it 'has no record count' do
          transform_status.record_count.should == 0
        end

        it 'has an error about the exit' do
          messages[2].should == "`bash #{script_name}` process exited with code 4"
        end
      end
    end

    describe 'working directory' do
      let(:dir) { tmpdir('bar') }

      before do
        write_script do |f|
          f.puts 'echo `pwd`'
        end

        options[:directory] = dir

        subject.transform(transform_status)
      end

      it 'switches to the specified directory before running' do
        messages.first.should == dir.to_s
      end
    end

    describe 'environment' do
      before do
        write_script do |f|
          f.puts 'echo $SOME_ENV'
          f.puts 'echo $BUNDLE_GEMFILE'
        end

        options[:environment] = { 'SOME_ENV' => 'staging' }

        subject.transform(transform_status)
      end

      it 'has the specified values' do
        messages.first.should == 'staging'
      end

      it 'excludes the parent bundler environment' do
        ENV['BUNDLE_GEMFILE'].should_not be_nil # setup
        messages.last.should == ''
      end

      it 'does not monkey with the parent environment' do
        ENV['SOME_ENV'].should be_nil
      end
    end

    describe 'standard error' do
      let(:replacement_stderr) { StringIO.new }

      before do
        pending 'not sure this is desirable'

        write_script do |f|
          f.puts 'echo "On SE" 1>&2'
        end

        begin
          old_err, $stderr = $stderr, replacement_stderr
          subject.transform(transform_status)
        ensure
          $stderr = old_err
        end
      end

      it 'does not go to the parent stream' do
        replacement_stderr.string.should == ''
      end

      it 'goes to the log'
    end
  end
end
