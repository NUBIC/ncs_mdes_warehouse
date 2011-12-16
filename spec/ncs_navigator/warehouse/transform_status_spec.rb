require File.expand_path('../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse
  class SampleRecordishThing
    include ::DataMapper::Resource
    property :record_id, Serial, :key => true
  end

  SampleRecordishThing.finalize

  describe TransformStatus do
    subject { TransformStatus.memory_only('DC') }

    describe '#unsuccessful_record' do
      let(:rec) { SampleRecordishThing.new.tap { |t| t.record_id = 42 } }
      let(:actual) { subject.transform_errors.last }

      before do
        subject.unsuccessful_record(rec, 'bad news')
      end

      it 'includes the record ID' do
        actual.record_id.should == '42'
      end

      it 'includes the class' do
        actual.model_class.should == SampleRecordishThing.to_s
      end

      it 'includes the message' do
        actual.message.should == 'bad news'
      end
    end
  end
end
