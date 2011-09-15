require File.expand_path('../../../spec_helper', __FILE__)

require 'zip/zip'

module NcsNavigator::Warehouse
  describe XmlEmitter, :use_mdes do
    let(:filename) { tmpdir + 'export.xml' }
    let(:xml) {
      XmlEmitter.new(filename, :quiet => true).emit_xml
      Nokogiri::XML(File.read(filename))
    }

    def person_model
      NcsNavigator::Warehouse.models_module.const_get(:Person)
    end

    before do
      NcsNavigator::Warehouse.models_module.mdes_order.each do |model|
        model.stub!(:all).and_return([])
      end
    end

    # Most of the details of the XML are tested on the MdesModel mixin
    describe 'the generated XML' do
      it 'includes the SC from the configuration' do
        xml.xpath('//sc_id').text.should == '2000042'
      end

      it 'includes the PSU from the configuration' do
        xml.xpath('//psu_id').text.should == '2000423'
      end

      it 'includes the appropriate specification version' do
        xml.xpath('//specification_version').text.
          should == NcsNavigator::Warehouse.mdes.specification_version
      end

      describe 'with actual data' do
        before do
          person_model.should_receive(:all).and_return([
              person_model.new(:person_id => 'XQ4'),
              person_model.new(:person_id => 'QX9')
            ])
        end

        it 'contains records for all models' do
          xml.xpath('//person').size.should == 2
        end

        it 'contains the right records' do
          xml.xpath('//person/person_id').collect { |e| e.text.strip }.should == %w(XQ4 QX9)
        end
      end
    end

    describe 'the generated ZIP file' do
      let(:expected_zipfile) { Pathname.new(filename.to_s + '.zip') }

      before do
        xml # for side effects
      end

      it 'exists' do
        expected_zipfile.should be_readable
      end

      it 'contains just the XML file' do
        contents = []
        Zip::ZipFile.foreach(expected_zipfile) do |entry|
          contents << entry.name
        end
        contents.should == [ filename.basename.to_s ]
      end

      it 'can be opened by something other than rubyzip' do
        `which unzip`
        pending "unzip is not available" unless $? == 0

        `unzip -l #{expected_zipfile} 2>&1`.should =~ /#{filename.basename}\s/
        $?.should == 0
      end
    end
  end
end
