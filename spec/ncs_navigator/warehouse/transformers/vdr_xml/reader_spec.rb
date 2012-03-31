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
      let(:study_center) { reader.detect { |rec| rec.class.name =~ /StudyCenter$/ } }
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

      it 'converts a -7 FK to no assocation' do
        listing_unit.tsu_id.should be_nil
      end

      it 'ignores random attributes' do
        listing_unit.list_source.should == "3"
      end

      it 'converts an "unknown" code in a text field to no value' do
        study_center.comments.should be_nil
      end

      it 'leaves alone "unknown" codes in coded fields' do
        person.sex.should == "-6"
      end

      it 'completely ignores records whose key is an "unknown" code' do
        reader.select { |rec| rec.class.name =~ /Ssu$/ }.collect(&:key).should == [['13']]
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

      it 'strips left over encoded CRs (#1940)' do
        person.person_comment.should == "Likes\r\nline\r\nbreaks"
      end
    end
  end
end
