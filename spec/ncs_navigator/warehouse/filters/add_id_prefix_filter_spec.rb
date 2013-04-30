require 'spec_helper'

module NcsNavigator::Warehouse::Filters
  describe AddIdPrefixFilter do
    let(:filter) {
      AddIdPrefixFilter.new(spec_config, options)
    }

    let(:options) {
      {
        :table => :participant,
        :prefix => 'PfX-'
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
      it 'prefixes the PK on a record of the specified type' do
        a_p = spec_config.model(:Participant).new(:p_id => '123')
        filter.call([a_p]).should == [a_p]
        a_p.p_id.should == 'PfX-123'
      end

      it 'does not prefix the PK on records of other types' do
        a_contact = spec_config.model(:Contact).new(:contact_id => '234')
        filter.call([a_contact]).should == [a_contact]
        a_contact.contact_id.should == '234'
      end

      it 'prefixes the FK on references to the specified type' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => '345', :person_id => '456')
        filter.call([a_link]).should == [a_link]
        a_link.p_id.should == 'PfX-345'
      end

      it 'does not prefix when the FK is nil' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => nil, :person_id => '456')
        filter.call([a_link]).should == [a_link]
        a_link.p_id.should be_nil
      end

      it 'does not prefix an FK which references a different type' do
        a_link = spec_config.model(:LinkPersonParticipant).new(
          :p_id => '345', :person_id => '456')
        filter.call([a_link]).should == [a_link]
        a_link.person_id.should == '456'
      end
    end
  end
end
