require File.expand_path('../../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::Transformers
  describe EnumTransformer, :modifies_warehouse_state do
    class Sample
      include ::DataMapper::Resource

      property :id, Integer, :key => true
      property :name, String, :required => true
    end

    before(:all) do
      DataMapper.finalize
    end

    describe '#transform' do
      let(:records) { [
          Sample.new(:id => 1, :name => 'One'),
          Sample.new(:id => 2, :name => 'Two'),
          Sample.new(:id => 3, :name => 'Three')
        ] }
      let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }
      subject { EnumTransformer.new(records) }

      it 'saves valid records when all are valid' do
        records.each do |m|
          m.should_receive(:valid?).and_return(true)
          m.should_receive(:save).and_return(true)
        end

        subject.transform(transform_status)
        transform_status.transform_errors.should be_empty
      end

      it 'automatically sets the PSU ID if the object accepts it'

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
          err.message.should == 'Invalid record. Name must not be blank (name=nil). Sample id=3.'
        end

        it 'saves the other instances' do
          # in `before`
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
          err.message.should == 'Could not save. Sample id=2.'
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
          err.message.should == 'Error on save. RuntimeError: No database around these parts. Sample id=1.'
        end

        it 'saves the saveable instances' do
          # in `before`
        end
      end
    end
  end
end
