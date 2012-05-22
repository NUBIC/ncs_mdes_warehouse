require 'spec_helper'

module NcsNavigator::Warehouse
  describe TransformLoad, :modifies_warehouse_state do
    let(:config) { base_config }
    let(:loader) { TransformLoad.new(config) }

    def base_config
      Configuration.new.tap do |c|
        c.bcdatabase_group = :test_sqlite
        c.log_file = tmpdir + "#{File.basename(__FILE__)}.log"
        c.output_level = :quiet
      end
    end

    before do
      use_test_bcdatabase

      # Not config due to RSpec #500
      DatabaseInitializer.new(base_config).tap do |dbi|
        dbi.set_up_repository(:both)
      end
      TransformError.auto_migrate!(:mdes_warehouse_working)
      TransformStatus.auto_migrate!(:mdes_warehouse_working)
    end

    describe '#run' do
      it 'runs the transformers in the order specified' do
        order = []
        config.add_transformer(BlockTransformer.new { |s| order << 'B' })
        config.add_transformer(BlockTransformer.new { |s| order << 'T' })
        config.add_transformer(BlockTransformer.new { |s| order << 'w' })

        loader.run

        order.should == %w(B T w)
      end

      it 'passes a separate instance of TransformStatus to each transformer' do
        statuses = []
        config.add_transformer(BlockTransformer.new { |s| statuses << s })
        config.add_transformer(BlockTransformer.new { |s| statuses << s })

        loader.run

        statuses.first.should_not be statuses.last
      end

      describe 'a created status' do
        let(:statuses) { [] }
        let(:status) { statuses.first }
        let(:transformer) { BlockTransformer.new { |s| statuses << s } }

        before do
          config.add_transformer(transformer)
        end

        it 'uses the name provided by the transformer, if any' do
          def transformer.name; 'provided'; end

          loader.run

          status.name.should == 'provided'
        end

        it 'uses the class name of the transformer otherwise' do
          loader.run

          status.name.should == 'BlockTransformer'
        end

        it 'sets the start and end times' do
          Time.should_receive(:now).and_return(Time.iso8601('2001-01-12T08:00:00'))
          Time.stub!(:now).and_return(Time.iso8601('2001-01-12T09:06:30'))

          loader.run

          status.start_time.hour.should == 8
          status.end_time.hour.should == 9
        end

        it 'sets the position' do
          loader.run
          status.position.should == 0
        end
      end

      it 'returns true if none of the transformers report an error' do
        config.add_transformer(BlockTransformer.new { |s| })
        loader.run.should be_true
      end

      describe 'with a reported error' do
        let(:runs) { [] }

        before do
          config.add_transformer(BlockTransformer.new { |s| runs << 'A' })
          config.add_transformer(BlockTransformer.new { |s|
              runs << 'B'
              s.unsuccessful_record(nil, 'fail')
            })
          config.add_transformer(BlockTransformer.new { |s| runs << 'C3' })
          @result = loader.run
        end

        it 'still runs all the transformers' do
          runs.should == %w(A B C3)
        end

        it 'returns false' do
          @result.should == false
        end
      end

      describe 'with a failure' do
        let(:runs) { [] }
        let(:statuses) { TransformStatus.all(:order => [:id.desc]) }

        before do
          config.add_transformer(BlockTransformer.new { |s| runs << 'A' })
          config.add_transformer(BlockTransformer.new { |s|
              runs << 'B'
              fail 'No thanks'
            })
          config.add_transformer(BlockTransformer.new { |s| runs << 'C3' })
          @result = loader.run
        end

        it 'still runs all the transformers' do
          runs.should == %w(A B C3)
        end

        it 'returns false' do
          @result.should == false
        end

        it 'records the error including the trace' do
          statuses[1].transform_errors.first.message.
            should =~ /No thanks\n.*#{File.basename(__FILE__)}:\s*\d+/
        end
      end

      describe 'with an integrity error on transaction commit' do
        let(:runs) { [] }

        before do
          config.add_transformer(BlockTransformer.new { |s| runs << 'A' })
          config.add_transformer(BlockTransformer.new { |s| runs << 'B' })
          config.add_transformer(BlockTransformer.new { |s| runs << 'C3' })

          TransformStatus.should_receive(:transaction).ordered.and_yield
          TransformStatus.should_receive(:transaction).ordered.
            and_raise(DataObjects::IntegrityError.new('Foo'))
          TransformStatus.should_receive(:transaction).ordered.and_yield

          loader.run
        end

        it 'records a TransformError' do
          TransformStatus.all[1].transform_errors.first.message.
            should =~ /^Transform failed with data integrity error: Foo/
        end

        it 'still runs all the transformers' do
          # this is not A B C3 due to a limitation in rspec-mocks --
          # you apparently can't .and_yield.and_raise and have both apply.
          runs.should == %w(A C3)
        end
      end

      describe 'with post-ETL hooks' do
        let(:hook_a) { RecordingHook.new }
        let(:hook_success) { RecordingHook.new(:succeeded) }
        let(:hook_failure) { RecordingHook.new(:failed) }
        let(:hook_error) {
          Class.new do
            def etl_succeeded(ts)
              fail 'Hook broke'
            end
            alias :etl_failed :etl_succeeded
          end.new
        }

        let(:hooks_invoked) {
          [hook_a, hook_success, hook_failure].map(&:invoked?)
        }

        before do
          config.add_post_etl_hook(hook_a)
          config.add_post_etl_hook(hook_success)
          config.add_post_etl_hook(hook_failure)
        end

        shared_examples 'all hooks' do
          before do
            loader.run
          end

          it 'sends each hook the statuses' do
            hook_a.transform_statuses.size.should == 1
          end

          it 'sends each hook the configuration' do
            hook_a.configuration.should == config
          end

          it 'runs all the hooks even when one fails' do
            config.post_etl_hooks.unshift hook_error

            loader.run

            hooks_invoked.should == expected_invoke_pattern
          end
        end

        describe 'when the transform fails' do
          let(:expected_invoke_pattern) { [true, false, true] }

          before do
            config.add_transformer(BlockTransformer.new { |s| fail 'Nope.' })
          end

          include_examples 'all hooks'

          it 'runs all the hooks that have an etl_failed method' do
            hooks_invoked.should == expected_invoke_pattern
          end

          it 'sends each hook the overall status' do
            hook_a.should be_failure
          end
        end

        describe 'when the transform succeeds' do
          let(:expected_invoke_pattern) { [true, true, false] }

          before do
            config.add_transformer(BlockTransformer.new { })
          end

          include_examples 'all hooks'

          it 'runs all the hooks that have an etl_succeeded method' do
            hooks_invoked.should == expected_invoke_pattern
          end

          it 'sends each hook the overall status' do
            hook_a.should be_success
          end
        end
      end

      # This is a crappy test; it would be better if it could be done
      # another way. Unfortunately, it doesn't look like DataMapper
      # exposes information to allow another way to check this.
      it "defeats DataMapper's caching" do
        seen_maps = []
        identity_map_tracker_transformer = BlockTransformer.new { |s|
          seen_maps << ::DataMapper::Repository.context.first.instance_eval { @identity_maps }
        }
        config.add_transformer(identity_map_tracker_transformer)
        config.add_transformer(identity_map_tracker_transformer)

        loader.run
        loader.statuses.collect { |s| s.transform_errors }.flatten.should == []

        seen_maps.should == [{}, {}]
      end
    end

    class ::BlockTransformer
      def initialize(&block)
        @block = block
      end

      def transform(status)
        @block.call(status)
      end
    end

    class ::RecordingHook
      attr_reader :transform_statuses, :configuration

      def initialize(*modes)
        @invoked = false
        @modes = modes.empty? ? [:succeeded, :failed] : modes

        @modes.each do |mode|
          instance_eval <<-RUBY
            def etl_#{mode}(args)
              @invoked = true
              @transform_statuses = args[:transform_statuses]
              @configuration = args[:configuration]
              @success = #{mode == :succeeded}
            end
          RUBY
        end
      end

      def invoked?
        @invoked
      end

      def success?
        @success
      end

      def failure?
        !@success.nil? && !@success
      end
    end
  end
end
