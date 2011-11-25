require File.expand_path('../../../spec_helper', __FILE__)

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

        before do
          config.add_transformer(BlockTransformer.new { |s| runs << 'A' })
          config.add_transformer(BlockTransformer.new { |s|
              runs << 'B'
              fail 'No thanks.'
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

      describe 'sending e-mail' do
        it 'sends on success'

        it 'sends on failure'
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
  end
end
