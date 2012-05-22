require 'spec_helper'

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

  describe TransformError do
    describe '.for_exception' do
      let(:exception) { begin; raise IndexError, 'Pick a different one'; rescue => e; e; end }
      let(:actual) { TransformError.for_exception(exception, 'What is happening?') }

      it 'provides a message' do
        actual.message.should_not be_nil
      end

      describe 'the message' do
        let(:message) { actual.message }

        it 'includes the provided context' do
          message.should =~ /What is happening\?/
        end

        it 'includes the exception type' do
          message.should =~ /IndexError/
        end

        it 'includes the exception message' do
          message.should =~ /Pick a different one/
        end

        it 'includes the stack trace' do
          message.should =~ /#{File.basename(__FILE__)}\:\s*\d+/
        end
      end
    end
  end
end
