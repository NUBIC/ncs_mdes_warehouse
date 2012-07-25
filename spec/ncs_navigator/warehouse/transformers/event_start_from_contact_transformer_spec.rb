require 'spec_helper'
require 'warehouse_record_creation_helpers'

module NcsNavigator::Warehouse::Transformers
  describe EventStartFromContactTransformer, :use_database, :slow do
    include_context :warehouse_record_creation_helpers

    let(:transformer) { EventStartFromContactTransformer.new(spec_config) }
    let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }

    def create_contact_for_event(event, contact_attributes)
      contact = create_warehouse_record_with_defaults(:Contact, contact_attributes)
      create_warehouse_record_with_defaults(:LinkContact,
        :contact_link_id => "LC_#{event.event_id}_#{contact.contact_id}",
        :event => event, :contact => contact, :staff => staff
        )
      contact
    end

    let(:staff) { create_warehouse_record_with_defaults(:Staff, :staff_id => 'foo') }

    let!(:ok_event) {
      create_warehouse_record_with_defaults(:Event,
        :event_id => 'E_OK', :event_start_date => '2010-09-04')
    }
    let!(:ok_event_contact) {
      create_contact_for_event(ok_event,
        :contact_id => 'C_OK', :contact_date => '2010-09-01')
    }

    let!(:bare_event) {
      create_warehouse_record_with_defaults(:Event,
        :event_id => 'E_BARE', :event_start_date => '9666-96-96'
      )
    }

    let!(:bad_event) {
      create_warehouse_record_with_defaults(:Event,
        :event_id => 'E_BAD', :event_start_date => '9666-96-96')
    }
    let!(:bad_event_contact_0) {
      create_contact_for_event(bad_event,
        :contact_id => 'C_BAD_0', :contact_date => '2010-02-07', :contact_start_time => '00:00')
    }
    let!(:bad_event_contact_1) {
      create_contact_for_event(bad_event,
        :contact_id => 'C_BAD_1', :contact_date => '2010-02-05', :contact_start_time => '96:96')
    }
    let!(:bad_event_contact_2) {
      create_contact_for_event(bad_event,
        :contact_id => 'C_BAD_2', :contact_date => '2010-02-05', :contact_start_time => '03:21')
    }
    let!(:bad_event_contact_3) {
      create_contact_for_event(bad_event,
        :contact_id => 'C_BAD_3', :contact_date => '2010-02-05', :contact_start_time => '02:34')
    }
    let!(:bad_event_contact_4) {
      create_contact_for_event(bad_event,
        :contact_id => 'C_BAD_4', :contact_date => '9666-97-97', :contact_start_time => '01:10')
    }

    def reload(record)
      record.model.first(record.model.key.first => record.key.first)
    end

    before do
      transformer.transform(transform_status)
    end

    it 'leaves events with start dates alone' do
      reload(ok_event).event_start_date.should == '2010-09-04'
    end

    it 'leaves events without contacts alone' do
      reload(bare_event).event_start_date.should == '9666-96-96'
    end

    describe 'for an event without a start date' do
      let(:fixed_event) { reload(bad_event) }

      it "takes the event start date from the earliest associated contact's start date" do
        fixed_event.event_start_date.should == '2010-02-05'
      end

      it "takes the event start time from the earliest associated contact's start time" do
        fixed_event.event_start_time.should == '02:34'
      end

      it 'records the number events changed' do
        transform_status.record_count.should == 1
      end
    end
  end
end
