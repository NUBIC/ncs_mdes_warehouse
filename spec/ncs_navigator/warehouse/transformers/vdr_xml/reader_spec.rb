require File.expand_path('../../../../../spec_helper', __FILE__)

class NcsNavigator::Warehouse::Transformers::VdrXml
  describe Reader, :use_mdes do
    describe '#each', :slow do
      let(:filename) { File.expand_path('../made_up_vdr_xml.xml', __FILE__) }
      let(:reader) { Reader.new(spec_config, filename) }
      let(:ssu)          { reader.detect { |rec| rec.class.name =~ /Ssu$/ } }
      let(:person)       { reader.detect { |rec| rec.class.name =~ /Person$/ } }
      let(:link_contact) { reader.detect { |rec| rec.class.name =~ /LinkContact$/ } }
      let(:listing_unit) { reader.detect { |rec| rec.class.name =~ /ListingUnit$/ } }
      let(:email)        { reader.detect { |rec| rec.class.name =~ /Email$/ } }

      it 'verifies the PSU matches the configuration'
      it 'verifies the specification version matches the runtime MDES version'

      it 'yields all records' do
        reader.to_a.size.should == 7
      end

      it 'yields the records using their model classes' do
        reader.collect { |rec| rec.class.name.demodulize }.should ==
          %w(StudyCenter Psu Ssu ListingUnit Person LinkContact Email)
      end

      it 'reads variable values' do
        person.first_name.should == 'Josephine'
      end

      it 'converts a -3 FK to no assocation' do
        person.new_address_id.should be_nil
      end

      it 'ignores random attributes' do
        listing_unit.list_line.should == "-7"
      end

      describe 'with a blank variable value' do
        it 'converts a blank FK to no association' do
          link_contact.instrument_id.should be_nil
        end

        it 'leaves another blank value as blank' do
          person.last_name.should == ''
        end
      end

      it 'handles table-named variables' do
        email.email.should == 'jo@example.net'
      end
    end
  end
end
