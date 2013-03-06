require 'spec_helper'

class NcsNavigator::Warehouse::Transformers::VdrXml
  describe Reader, :use_mdes do
    let(:filename) { File.expand_path('../made_up_vdr_xml.xml', __FILE__) }
    let(:reader) { Reader.new(spec_config, filename) }

    describe '#name' do
      it 'includes the filename when present' do
        reader.name.should == "VDR XML #{filename}"
      end

      it 'includes the IO string rep if no filename' do
        Reader.new(spec_config, StringIO.new).name.should =~ /VDR XML #<StringIO/
      end
    end

    describe '#each', :slow do
      let(:ssu)          { reader.detect { |rec| rec.class.name =~ /Ssu$/ } }
      let(:person)       { reader.detect { |rec| rec.class.name =~ /Person$/ } }
      let(:link_contact) { reader.detect { |rec| rec.class.name =~ /LinkContact$/ } }
      let(:listing_unit) { reader.detect { |rec| rec.class.name =~ /ListingUnit$/ } }
      let(:study_center) { reader.detect { |rec| rec.class.name =~ /StudyCenter$/ } }
      let(:email)        { reader.detect { |rec| rec.class.name =~ /Email$/ } }

      it 'verifies the PSU matches the configuration'
      it 'verifies the specification version matches the runtime MDES version'

      it 'yields all records' do
        reader.to_a.size.should == 8
      end

      it 'yields the records using their model classes' do
        reader.collect { |rec| rec.class.name.demodulize }.should ==
          %w(StudyCenter Psu Ssu Ssu ListingUnit Person LinkContact Email)
      end

      it 'reads variable values' do
        person.first_name.should == 'Josephine'
      end

      it 'ignores random attributes' do
        listing_unit.list_source.should == "3"
      end

      it 'handles table-named variables' do
        email.email.should == 'jo@example.net'
      end

      it 'strips left over encoded CRs (#1940)' do
        person.person_comment.should == "Likes\r\nline\r\nbreaks"
      end

      it 'reads xsi:nil as nil' do
        person.person_dob.should be_nil
      end

      it 'handles completely empty elements' do
        person.last_name.should == ""
      end

      it 'handles values that occur after completely empty elements' do
        person.suffix.should == '-7'
      end
    end
  end
end
