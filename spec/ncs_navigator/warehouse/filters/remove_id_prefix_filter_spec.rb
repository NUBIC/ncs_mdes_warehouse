require 'spec_helper'

module NcsNavigator::Warehouse::Filters
  describe RemoveIdPrefixFilter do
    let(:filter) {
      RemoveIdPrefixFilter.new(spec_config, options)
    }

    let(:options) {
      {
        :table => :participant,
        :prefix => 'ZAP-'
      }
    }

    describe '#initialize' do
      it 'objects if there is no prefix' do
        options.delete(:prefix)

        expect { filter }.to raise_error('Please specify a :prefix.')
      end

      it 'does not object if there is a prefix' do
        expect { filter }.to_not raise_error
      end

      it 'objects if there is no table or model' do
        options.delete(:table)

        expect { filter }.to raise_error('Please specify either :table or :model.')
      end

      it 'accepts a known table' do
        options[:table] = :link_person_participant

        filter.model.should == spec_config.model(:LinkPersonParticipant)
      end

      it 'accepts a known model' do
        options.delete(:table)
        options[:model] = :LinkContact

        filter.model.should == spec_config.model(:link_contact)
      end
    end

    describe '#call' do
      it 'removes the prefix from a record of the specified type' do
        a_p = spec_config.model(:Participant).new(:p_id => 'ZAP-123')
        filter.call([a_p]).should == [a_p]
        a_p.p_id.should == '123'
      end

      it 'does not remove the prefix if it is not present' do
        a_p = spec_config.model(:Participant).new(:p_id => '321')
        filter.call([a_p]).should == [a_p]
        a_p.p_id.should == '321'
      end

      it 'does not touch a prefix on the PK on records of other types' do
        a_contact = spec_config.model(:Contact).new(:contact_id => 'ZAP-234')
        filter.call([a_contact]).should == [a_contact]
        a_contact.contact_id.should == 'ZAP-234'
      end

      it 'removes the prefix from the FK on references to the specified type' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => 'ZAP-345', :person_id => 'ZAP-456')
        filter.call([a_link]).should == [a_link]
        a_link.p_id.should == '345'
      end

      it 'does not remove the prefix when it is not set' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => '543', :person_id => '654')
        filter.call([a_link]).should == [a_link]
        a_link.p_id.should == '543'
      end

      it 'does not remove the prefix from the FK which references a different type' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => 'ZAP-345', :person_id => 'ZAP-456')
        filter.call([a_link]).should == [a_link]
        a_link.person_id.should == 'ZAP-456'
      end

      it 'does not fail when the FK is nil' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => nil, :person_id => '654')
        filter.call([a_link]).should == [a_link]
        a_link.p_id.should be_nil
      end
    end
  end
end
