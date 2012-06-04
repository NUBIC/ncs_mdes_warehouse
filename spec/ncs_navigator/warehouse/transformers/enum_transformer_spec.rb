require 'spec_helper'

require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Transformers
  describe EnumTransformer, :modifies_warehouse_state do
    class Sample
      include ::DataMapper::Resource

      property :psu_id, String
      property :recruit_type, String
      property :id, Integer, :key => true
      property :name, String, :required => true
    end

    class Subsample
      include ::DataMapper::Resource

      property :id, Integer, :key => true
      belongs_to :sample,
        'NcsNavigator::Warehouse::Transformers::Sample', :child_key => [ :sample_id ]
    end

    before(:all) do
      DataMapper.finalize
    end

    describe '#transform' do
      let(:config) {
        NcsNavigator::Warehouse::Configuration.new.tap do |c|
          c.log_file = tmpdir + 'enum_transformer_test.log'
        end
      }
      let(:records) { [
          Sample.new(:id => 1, :name => 'One'),
          Sample.new(:id => 2, :name => 'Two'),
          Sample.new(:id => 3, :name => 'Three')
        ] }
      let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }
      subject { EnumTransformer.new(config, records) }

      it 'saves valid records when all are valid' do
        records.each do |m|
          m.should_receive(:valid?).and_return(true)
          m.should_receive(:save).and_return(true)
        end

        subject.transform(transform_status)
        transform_status.transform_errors.should be_empty
      end

      it 'automatically sets the PSU ID if necessary' do
        records[1].psu_id = '20000042'

        records.each do |m|
          m.should_receive(:valid?).and_return(true)
          m.should_receive(:save).and_return(true)
        end

        subject.transform(transform_status)
        records.collect(&:psu_id).should == %w(20000030 20000042 20000030)
      end

      it 'automatically sets recruit_type if necessary' do
        records[2].recruit_type = '1'

        records.each do |m|
          m.should_receive(:valid?).and_return(true)
          m.should_receive(:save).and_return(true)
        end

        subject.transform(transform_status)
        records.collect(&:recruit_type).should == %w(3 3 1)
      end

      describe 'with an invalid instance' do
        before do
          records[0].should_receive(:save).and_return(true)
          records[1].should_receive(:save).and_return(true)
          records[2].name = nil

          subject.transform(transform_status)
        end

        it 'records the invalid instance' do
          err = transform_status.transform_errors.first
          err.model_class.should == Sample.to_s
          err.record_id.should == '3'
          err.message.should == 'Invalid record. Name must not be blank (name=nil).'
        end

        it 'saves the other instances' do
          # in `before`
        end
      end

      describe 'with an instance with an invalid PSU' do
        before do
          records[0].should_receive(:save).and_return(true)
          records[1].should_not_receive(:save)
          records[2].should_receive(:save).and_return(true)

          records[1].psu_id = '20000041'
        end

        it 'does not save that instance' do
          subject.transform(transform_status)
        end

        it 'saves the other instances' do
          subject.transform(transform_status)
        end

        it 'records an error' do
          subject.transform(transform_status)
          transform_status.transform_errors.collect(&:record_id).should == ['2']
        end

        describe 'the recorded error' do
          let(:error) { transform_status.transform_errors.first }

          before do
            subject.transform(transform_status)
          end

          it 'has the correct model class' do
            error.model_class.should == Sample.to_s
          end

          it 'has the record ID' do
            error.record_id.should == '2'
          end

          it 'has a message' do
            error.message.should ==
              'Invalid PSU ID "20000041". The list of valid PSU IDs for this Study Center is ["20000030", "20000042"].'
          end
        end
      end

      describe 'with an unsatisfied foreign key' do
        let(:error) { transform_status.transform_errors.first }

        before do
          records << Subsample.new(:id => 3, :sample_id => 912)

          records.each do |m|
            m.stub!(:valid?).and_return(true)
            m.stub!(:save).and_return(true)
          end

          subject.transform(transform_status)
        end

        it 'reports the unsatisfied foreign key' do
          error.message.should =~ /Unsatisfied foreign key sample_id=912/
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
    end
  end
end
