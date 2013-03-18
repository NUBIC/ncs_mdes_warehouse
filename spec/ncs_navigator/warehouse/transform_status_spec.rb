require 'spec_helper'

require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse
  class SampleRecordishThing
    include ::DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'sample_thing'

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

      it 'includes the table_name' do
        actual.table_name.should == 'sample_thing'
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

    describe '#to_json' do
      let(:error) {
        TransformError.new(
          :message => "It's\n complicated",
          :model_class => SampleRecordishThing,
          :record_id => '45-T',
          :attribute_name => 'Fred',
          :attribute_value => 'MacMurray'
        )
      }
      let(:json) { error.to_json }
      let(:parsed) { JSON.parse(json) }

      it 'is a single line' do
        json.should_not =~ /\n/
      end

      describe 'the JSON contents' do
        %w(message model_class record_id attribute_name attribute_value).each do |prop|
          it "includes the #{prop.gsub('_', ' ')}" do
            parsed[prop].should == error.send(prop)
          end

          it "does not include #{prop.gsub('_', ' ')} when it isn't set" do
            error.send("#{prop}=", nil)
            parsed.should_not have_key(prop)
          end
        end

        it 'never contains the transform status ID' do
          error.transform_status_id = 5
          parsed.should_not have_key('transform_status_id')
        end

        it "never contains the error's own ID" do
          error.id = 7
          parsed.should_not have_key('id')
        end
      end
    end

    describe '#table_name' do
      it 'is set from the table name of the model class when a model class is set' do
        TransformError.new(:model_class => SampleRecordishThing).table_name.should == 'sample_thing'
      end

      it 'is not set when the model class is set to a string' do
        TransformError.new(:model_class => 'SampleRecordishThing').table_name.should be_nil
      end

      it 'is set to nil when the model class is set to nil' do
        TransformError.new(:model_class => nil).table_name.should be_nil
      end
    end
  end
end
