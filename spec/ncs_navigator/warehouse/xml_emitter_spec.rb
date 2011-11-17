require File.expand_path('../../../spec_helper', __FILE__)

require 'zip/zip'

module NcsNavigator::Warehouse
  describe XmlEmitter, :use_mdes do
    let(:filename) { tmpdir + 'export.xml' }
    let(:xml) {
      XmlEmitter.new(spec_config, filename).emit_xml
      Nokogiri::XML(File.read(filename))
    }

    def person_model
      spec_config.models_module.const_get(:Person)
    end

    before do
      spec_config.models_module.mdes_order.each do |model|
        model.stub!(:all).and_return([])
      end
    end

    # Most of the details of the XML are tested on the MdesModel mixin
    describe 'the generated XML', :slow do
      it 'includes the SC from the configuration' do
        xml.xpath('//sc_id').text.should == '20000029'
      end

      it 'includes the PSU from the configuration' do
        xml.xpath('//psu_id').text.should == '20000030'
      end

      it 'includes the appropriate specification version' do
        xml.xpath('//specification_version').text.
          should == spec_config.mdes.specification_version
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

    describe 'the generated ZIP file', :slow do
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

        `unzip -l '#{expected_zipfile}' 2>&1`.should =~ /#{filename.basename}\s/
        $?.should == 0
      end
    end

    describe 'the default filename', :slow, :use_mdes do
      subject { XmlEmitter.new(spec_config, nil).filename }

      before do
        pending "ncs_mdes doesn't work on JRuby" if RUBY_PLATFORM == 'java'

        # Need an actual PSU ID for the default filename code to work
        NcsNavigator.configuration.psus.first.id = '20000216'

        # Time.parse uses Time.now internally, so this needs to be
        # defined before starting to register the mock.
        t = Time.parse('2011-07-28')
        Time.should_receive(:now).and_return(t)
      end

      it 'is county_name-DATE.xml' do
        subject.to_s.should == 'bear_lake-20110728.xml'
      end

      it 'is a Pathname' do
        subject.should be_a Pathname
      end
    end
  end
end
