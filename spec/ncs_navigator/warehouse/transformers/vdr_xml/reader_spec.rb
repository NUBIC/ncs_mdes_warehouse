require File.expand_path('../../../../../spec_helper', __FILE__)

class NcsNavigator::Warehouse::Transformers::VdrXml
  describe Reader, :use_mdes do
    describe '#each', :slow do
      let(:filename) { File.expand_path('../made_up_vdr_xml.xml', __FILE__) }
      let(:reader) { Reader.new(spec_config, filename) }
      let(:ssu)          { reader.detect { |rec| rec.class.name =~ /Ssu$/ } }
      let(:person)       { reader.detect { |rec| rec.class.name =~ /Person$/ } }
      let(:link_contact) { reader.detect { |rec| rec.class.name =~ /LinkContact$/ } }

      it 'verifies the PSU matches the configuration'
      it 'verifies the specification version matches the runtime MDES version'

      it 'yields all records' do
        reader.to_a.size.should == 6
      end

      it 'yields the records using their model classes' do
        reader.collect { |rec| rec.class.name.demodulize }.should ==
          %w(StudyCenter Psu Ssu ListingUnit Person LinkContact)
      end

      it 'reads attribute values' do
        ssu.ssu_name.should == 'The unluckiest SSU'
      end

      it 'converts a -3 FK to no assocation' do
        person.new_address_id.should be_nil
      end

      describe 'with a blank variable value' do
        it 'converts a blank FK to no association' do
          link_contact.instrument_id.should be_nil
        end

        it 'leaves another blank value as blank' do
          person.first_name.should == ''
        end
      end
    end
  end
end
