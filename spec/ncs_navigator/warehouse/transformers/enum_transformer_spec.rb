require 'spec_helper'

require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Transformers
  describe EnumTransformer, :modifies_warehouse_state do
    class Sample
      include ::DataMapper::Resource

      property :psu_id, String
      property :recruit_type, String, :format => /^\d$/
      property :id, Integer, :key => true
      property :name, String, :required => true
    end

    class Subsample
      include ::DataMapper::Resource

      property :id, Integer, :key => true
      property :name, String, :length => (1..100)
      property :age, Integer
      belongs_to :sample,
        'NcsNavigator::Warehouse::Transformers::Sample', :child_key => [ :sample_id ], :required => false
    end

    before(:all) do
      DataMapper.finalize
    end

    shared_examples 'a foreign key index updater' do
      it 'records the IDs of saved records as seen' do
        expected_saved_record_ids.each do |id|
          foreign_key_index.seen?(Sample, id).should be_true
        end
      end

      it 'does not record the IDs of not-saved records as seen' do
        expected_not_saved_record_ids.each do |id|
          foreign_key_index.seen?(Sample, id).should be_false
        end
      end
    end

    describe '#transform' do
      let(:config) {
        NcsNavigator::Warehouse::Configuration.new.tap do |c|
          c.log_file = tmpdir + 'enum_transformer_test.log'
          c.foreign_key_index = foreign_key_index
        end
      }
      let(:records) { [
          Sample.new(:id => 1, :psu_id => '20000030', :name => 'One'),
          Sample.new(:id => 2, :psu_id => '20000030', :name => 'Two'),
          Sample.new(:id => 3, :psu_id => '20000030', :name => 'Three')
        ] }
      let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }
      let(:foreign_key_index) { ForeignKeyIndex.new(:existing_key_provider => nil) }
      subject { EnumTransformer.new(config, records) }

      it 'saves valid records when all are valid' do
        records.each do |m|
          m.should_receive(:valid?).and_return(true)
          m.should_receive(:save).and_return(true)
        end

        subject.transform(transform_status)
        transform_status.transform_errors.should == []
      end

      describe 'with an invalid instance' do
        before do
          records[0].should_receive(:save).and_return(true)
          records[1].should_receive(:save).and_return(true)
          records[2].name = nil
          records[2].recruit_type = 'H'

          subject.transform(transform_status)
        end

        it 'records each invalidity separately' do
          transform_status.transform_errors.size.should == 2
        end

        describe 'the error for an invalidity' do
          let(:err) { transform_status.transform_errors.sort_by { |te| te.message }.last }

          it "knows the record's class" do
            err.model_class.should == Sample.to_s
          end

          it 'knows the record ID' do
            err.record_id.should == '3'
          end

          it 'has the invalidity message' do
            err.message.should == 'Invalid: Recruit type has an invalid format.'
          end

          it 'knows the invalid attribute' do
            err.attribute_name.should == 'recruit_type'
          end

          it 'knows the invalid value' do
            err.attribute_value.should == '"H"'
          end
        end

        it 'saves the other instances' do
          # in `before`
        end

        let(:expected_saved_record_ids) { [1, 2] }
        let(:expected_not_saved_record_ids) { [3] }

        include_examples 'a foreign key index updater'
      end

      describe 'with an instance with an invalid PSU' do
        before do
          records[0].should_receive(:save).and_return(true)
          records[1].should_not_receive(:save)
          records[2].should_receive(:save).and_return(true)

          records[1].psu_id = '20000041'

          subject.transform(transform_status)
        end

        it 'does not save that instance' do
          # in before
        end

        it 'saves the other instances' do
          # in before
        end

        it 'records an error' do
          transform_status.transform_errors.collect(&:record_id).should == ['2']
        end

        describe 'the recorded error' do
          let(:error) { transform_status.transform_errors.first }

          it 'has the correct model class' do
            error.model_class.should == Sample.to_s
          end

          it 'has the record ID' do
            error.record_id.should == '2'
          end

          it 'has a message' do
            error.message.should ==
              'Invalid PSU ID. The list of valid PSU IDs for this Study Center is ["20000030", "20000042"].'
          end

          it 'has the PSU attribute' do
            error.attribute_name.should == 'psu_id'
          end

          it 'has the invalid value' do
            error.attribute_value.should == '"20000041"'
          end
        end

        let(:expected_saved_record_ids) { [1, 3] }
        let(:expected_not_saved_record_ids) { [2] }

        include_examples 'a foreign key index updater'
      end

      describe 'with an initially unsatisfied foreign key' do
        let(:unsatisfied) { Subsample.new(:id => 3, :sample_id => 912, :name => '') }
        let(:satisfier) { Sample.new(:id => unsatisfied.sample_id, :psu_id => '20000030', :name => 'Nine') }

        let(:fk_error) {
          transform_status.transform_errors.detect { |error| error.message =~ /foreign/i }
        }

        let(:validation_error) {
          transform_status.transform_errors.detect { |error| error.message =~ /valid/i }
        }

        before do
          records.each do |m|
            m.stub!(:valid?).and_return(true)
            m.stub!(:save).and_return(true)
          end

          records << unsatisfied
        end

        describe 'when the record is otherwise valid' do
          before do
            unsatisfied.name = 'Foo'
            unsatisfied.should be_valid # setup
          end

          describe 'and the foreign key is never satisfied' do
            it 'reports the unsatisfied foreign key' do
              unsatisfied.stub!(:save).and_return(true)
              subject.transform(transform_status)

              [fk_error.attribute_name, fk_error.attribute_value].should == ['sample_id', '912']
            end

            it 'does not save the record with the unsatisfied key' do
              unsatisfied.should_not_receive(:save)

              subject.transform(transform_status)
            end
          end

          describe 'and the foreign key is eventually satisfied' do

            before do
              satisfier.stub!(:valid?).and_return(true)
              satisfier.stub!(:save).and_return(true)
              records << satisfier
            end

            it 'does not report any errors' do
              transform_status.transform_errors.should == []
            end

            it 'saves the record with the eventually satisfied key' do
              satisfier.should_receive(:save)

              subject.transform(transform_status)
            end
          end
        end

        describe 'when the record has invalid properties' do
          before do
            unsatisfied.name = ''
            unsatisfied.should_not be_valid # setup
          end

          describe 'and the foreign key is never satisfied' do
            it 'reports the unsatisfied foreign key' do
              subject.transform(transform_status)

              [fk_error.attribute_name, fk_error.attribute_value].should == ['sample_id', '912']
            end

            it 'reports the invalid values' do
              subject.transform(transform_status)

              validation_error.attribute_name.should == 'name'
            end

            it 'does not save the record with the unsatisfied key' do
              unsatisfied.should_not_receive(:save)

              subject.transform(transform_status)
            end
          end

          describe 'and the foreign key is eventually satisfied' do
            before do
              satisfier.stub!(:valid?).and_return(true)
              satisfier.stub!(:save).and_return(true)
              records << satisfier
            end

            it 'does not report a foreign key problem' do
              subject.transform(transform_status)

              fk_error.should be_nil
            end

            it 'does report the invalid value' do
              subject.transform(transform_status)

              validation_error.attribute_name.should == 'name'
            end

            it 'does not save the record' do
              unsatisfied.should_not_receive(:save)

              subject.transform(transform_status)
            end
          end
        end
      end

      describe 'with an unsaveable instance' do
        before do
          records[0].should_receive(:save).and_return(true)
          records[1].should_receive(:save).and_return(false)
          records[2].should_receive(:save).and_return(true)

          subject.transform(transform_status)
        end

        it 'records the unsaveable instance' do
          err = transform_status.transform_errors.first
          err.model_class.should == Sample.to_s
          err.record_id.should == '2'
          err.message.should =~ /^Could not save valid record/
        end

        it 'saves the saveable instances' do
          # in `before`
        end

        let(:expected_saved_record_ids) { [1, 3] }
        let(:expected_not_saved_record_ids) { [2] }

        include_examples 'a foreign key index updater'
      end

      describe 'with an instance that errors on save' do
        before do
          records[0].should_receive(:save).and_raise("No database around these parts")
          records[1].should_receive(:save).and_return(true)
          records[2].should_receive(:save).and_return(true)

          subject.transform(transform_status)
        end

        it 'records the failing instance' do
          err = transform_status.transform_errors.first
          err.model_class.should == Sample.to_s
          err.record_id.should == '1'
          err.message.should ==
            'Error on save. RuntimeError: No database around these parts.'
        end

        it 'saves the saveable instances' do
          # in `before`
        end

        let(:expected_saved_record_ids) { [2, 3] }
        let(:expected_not_saved_record_ids) { [1] }

        include_examples 'a foreign key index updater'
      end

      describe 'with an enumeration that throws an exception' do
        let(:failing_enum) {
          Class.new do
            include Enumerable

            def initialize(records); @records = records; end

            def each
              @records.each_with_index do |r, i|
                if i == 2
                  raise IndexError, "don't like 2"
                else
                  yield r
                end
              end
            end
          end.new(records)
        }

        subject { EnumTransformer.new(config, failing_enum) }

        let(:error) {
          transform_status.should have(1).transform_errors
          transform_status.transform_errors.first
        }

        before do
          records.each do |m|
            m.stub!(:valid?).and_return(true)
            m.stub!(:save).and_return(true)
          end

          subject.transform(transform_status)
        end

        it 'records the exception type' do
          error.message.should =~ /IndexError/
        end

        it 'records the exception message' do
          error.message.should =~ /don't like 2/
        end

        it 'records the stacktrace' do
          error.message.should =~ /#{File.basename(__FILE__)}:\s*\d+/
        end
      end

      describe 'with an enumeration that yields a transform error' do
        before do
          records.each do |m|
            m.should_receive(:valid?).and_return(true)
            m.should_receive(:save).and_return(true)
          end

          records[1, 0] = NcsNavigator::Warehouse::TransformError.
            new(:message => 'I give up', :id => -922)

          subject.transform(transform_status)
        end

        it 'saves all the good records' do
          # in before
        end

        it 'associates the error with the status' do
          transform_status.transform_errors.collect(&:message).should == ['I give up']
        end

        it 'ignores any provided error id' do
          transform_status.transform_errors.first.id.should be_nil
        end
      end

      describe 'with a filter set' do
        let(:filter_one) { lambda { |recs| recs.each { |r| r.name = 'FILTERED' }; recs } }
        let(:filter_two) { lambda { |recs| recs.each { |r| r.name.downcase! }; recs } }
        let(:replacing_filter) { lambda { |recs| [records[1]] } }

        def transformer_with_filters(*filters)
          EnumTransformer.new(config, records, :filters => filters)
        end

        before do
          records.each do |r|
            r.stub!(:valid?).and_return(true)
            r.stub!(:save).and_return(true)
          end
        end

        it 'applies all the filters' do
          transformer_with_filters(filter_one, filter_two).transform(transform_status)

          records.each { |m| m.name.should == 'filtered' }
        end

        it 'saves only the results from the filter' do
          records[0].should_not_receive(:save)
          records[2].should_not_receive(:save)
          records[1].should_receive(:save).exactly(3).times.and_return(true)

          transformer_with_filters(replacing_filter).transform(transform_status)
        end

        context do
          before do
            transformer_with_filters(replacing_filter).transform(transform_status)
          end

          let(:expected_saved_record_ids) { [2] }
          let(:expected_not_saved_record_ids) { [1, 3] }

          include_examples 'a foreign key index updater'
        end
      end

      describe 'duplicates modes' do
        let(:sample_1_en) { Subsample.new(:id => 1, :name => 'One', :age => 80) }
        let(:sample_1_es) { Subsample.new(:id => 1, :name => 'Uno', :age => nil) }

        let(:records) { [sample_1_en, sample_1_es] }

        def transformer_for_dups(mode)
          EnumTransformer.new(config, records, :duplicates => mode)
        end

        it 'defaults the duplicates mode to :error' do
          EnumTransformer.new(config, records).duplicates.should == :error
        end

        it 'accepts a duplicates mode option' do
          transformer_for_dups(:ignore).duplicates.should == :ignore
        end

        it 'fails for an unknown duplicates mode' do
          lambda { transformer_for_dups(:explode) }.
            should raise_error(/Unknown duplicates mode :explode\./)
        end

        describe ':error' do
          it 'tries to save everything' do
            sample_1_en.should_receive(:save).and_return(true)
            sample_1_es.should_receive(:save).and_return(true)

            # If we weren't mocking, the transaction commit would result in
            # an exception. I don't think it's important to test that here.
            transformer_for_dups(:error).transform(transform_status)
            transform_status.transform_errors.should == []
          end
        end

        describe ':ignore' do
          it 'does not try to save the duplicate' do
            sample_1_en.should_receive(:save).and_return(true)
            sample_1_es.should_not_receive(:save)

            transformer_for_dups(:ignore).transform(transform_status)
            transform_status.transform_errors.should == []
          end
        end

        describe ':replace' do
          let(:reloaded_sample) { sample_1_en.clone }

          before do
            sample_1_en.should_receive(:save).once.and_return(true)
            sample_1_es.should_not_receive(:save)

            Subsample.should_receive(:get).with(1).and_return(reloaded_sample)
            reloaded_sample.should_receive(:save).once.and_return(true)

            transformer_for_dups(:replace).transform(transform_status)
          end

          it 'loads and updates the existing record' do
            transform_status.transform_errors.should == []
          end

          it 'replaces a set property with a new value' do
            reloaded_sample.name.should == 'Uno'
          end

          it 'replaces a nil property with nil' do
            reloaded_sample.age.should be_nil
          end
        end
      end
    end
  end
end
