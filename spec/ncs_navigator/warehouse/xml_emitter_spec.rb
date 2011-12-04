require File.expand_path('../../../spec_helper', __FILE__)

require 'zip/zip'

module NcsNavigator::Warehouse
  describe XmlEmitter, :use_mdes do
    let(:filename) { tmpdir + 'export.xml' }
    let(:options) { {} }
    let(:xml) {
      XmlEmitter.new(spec_config, filename, options).emit_xml
      Nokogiri::XML(File.read(filename))
    }

    def person_model
      spec_config.models_module.const_get(:Person)
    end

    def participant_model
      spec_config.models_module.const_get(:Participant)
    end

    def stub_model(model)
      model.stub!(:count).and_return(0)
    end

    before do
      spec_config.models_module.mdes_order.reject { |m|
        [person_model, participant_model].include?(m)
      }.each do |model|
        stub_model(model)
      end
    end

    # Most of the details of the XML are tested on the MdesModel mixin
    describe 'the generated XML', :slow do
      describe 'global attributes' do
        before do
          stub_model(person_model)
          stub_model(participant_model)
        end

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
      end

      def default_required_attributes(model)
        model.properties.select { |prop| prop.required? }.inject({}) { |h, prop|
          h[prop.name] = '-4'; h
        }
      end

      def create_instance(model, attributes)
        model.new(default_required_attributes(model).merge(attributes))
      end

      def create_person(id, attributes={})
        create_instance(person_model, { :person_id => id }.merge(attributes))
      end

      describe 'with exactly one actual record', :slow, :use_database do
        let(:records) {
          [
            create_person('XQ4')
          ]
        }

        before do
          pending 'Not working in CI at the moment' if ENV['CI_RUBY']
          records.each { |rec| rec.save or fail "Save of #{rec.inspect} failed." }
        end

        it 'contains records for all models' do
          xml.xpath('//person').size.should == 1
        end

        it 'contains the right records' do
          xml.xpath('//person/person_id').collect { |e| e.text.strip }.sort.should == %w(XQ4)
        end
      end

      describe 'with actual data', :slow, :use_database do
        let(:records) {
          [
            create_person('XQ4', :first_name => 'Xavier'),
            create_person('QX9', :first_name => 'Quentin'),
            create_instance(participant_model, :p_id => 'P_QX4')
          ]
        }

        before do
          pending 'Not working in CI at the moment' if ENV['CI_RUBY']
          records.each { |rec| rec.save or fail "Save of #{rec.inspect} failed." }
        end

        it 'contains records for all models' do
          xml.xpath('//person').size.should == 2
        end

        it 'contains the right records' do
          xml.xpath('//person/person_id').collect { |e| e.text.strip }.sort.should == %w(QX9 XQ4)
        end

        describe 'and PII' do
          let(:xml_first_names) {
            xml.xpath('//person/first_name').collect { |e| e.text.strip }.sort
          }

          it 'excludes PII by default' do
            xml_first_names.should == ['', '']
          end

          it 'excludes PII when explicitly excluded' do
            options[:'include-pii'] = false
            xml_first_names.should == ['', '']
          end

          it 'includes PII when requested' do
            options[:'include-pii'] = true
            xml_first_names.should == %w(Quentin Xavier)
          end
        end

        describe 'and selected output' do
          let(:people_count) { xml.xpath('//person').size }
          let(:p_count) { xml.xpath('//participant').size }

          it 'includes all tables by default' do
            people_count.should == 2
            p_count.should == 1
          end

          it 'includes only the selected tables when requested' do
            options[:tables] = %w(participant)

            people_count.should == 0
            p_count.should == 1
          end

          it 'includes all the requested tables when explicitly requested' do
            options[:tables] = spec_config.models_module.mdes_order.collect(&:mdes_table_name)

            people_count.should == 2
            p_count.should == 1
          end
        end
      end

      describe 'with lots and lots of actual data', :slow, :use_database do
        let(:count) { 3134 }
        let(:records) { (0...count).collect { |n| create_person(n) } }
        let(:actual_ids) { xml.xpath('//person/person_id').collect { |e| e.text.strip } }

        before do
          pending 'Not working in CI at the moment' if ENV['CI_RUBY']
          records.each { |rec| rec.save or fail "Save of #{rec.inspect} failed." }
        end

        it 'contains all the records' do
          actual_ids.size.should == count
        end

        it 'contains the right records' do
          actual_ids.collect(&:to_i).sort[2456].should == 2456
        end
      end
    end

    describe 'the generated ZIP file', :slow do
      let(:expected_zipfile) { Pathname.new(filename.to_s + '.zip') }

      before do
        stub_model(person_model)
        stub_model(participant_model)
      end

      context do
        def actual
          xml
          expected_zipfile
        end

        it 'exists by default' do
          actual.should be_readable
        end

        it 'exists if explicitly requested' do
          options[:zip] = true
          actual.should be_readable
        end

        it 'does not exist when excluded' do
          options[:zip] = false
          actual.exist?.should be_false
        end
      end

      context do
        before do
          xml # for side effects
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
