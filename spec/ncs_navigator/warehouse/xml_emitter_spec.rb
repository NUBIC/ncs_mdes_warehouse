require 'spec_helper'

require 'zip/zip'

module NcsNavigator::Warehouse
  describe XmlEmitter, :use_mdes do
    let(:filename) { tmpdir + 'export.xml' }
    let(:options) { { :zip => false } }
    let(:emitter) { XmlEmitter.new(spec_config, filename, options) }
    let(:xml) {
      emitter.emit_xml
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
          xml.xpath('//person/person_id').collect { |e| e.text.strip }.should == %w(QX9 XQ4)
        end

        describe 'and including PII in a single file' do
          let(:xml_first_names) {
            xml.xpath('//person/first_name').collect { |e| e.text.strip }
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

        describe 'and creating both with- and without-PII variants in parallel' do
          let(:no_pii_file) { emitter.xml_files.find { |xf| !xf.include_pii? }.filename }
          let(:pii_file) { emitter.xml_files.find { |xf| xf.include_pii? }.filename }

          let(:no_pii_xml) { Nokogiri::XML(no_pii_file.read) }
          let(:pii_xml) { Nokogiri::XML(pii_file.read) }

          def first_names_in(xml)
            xml.xpath('//person/first_name').collect { |e| e.text.strip }.sort
          end

          before do
            options[:'and-pii'] = true
            emitter.emit_xml
          end

          it 'creates the expected with-PII file' do
            pii_file.exist?.should be_true
          end

          it 'creates the expected without-PII file' do
            no_pii_file.exist?.should be_true
          end

          it 'includes PII in the PII file' do
            first_names_in(pii_xml).should == %w(Quentin Xavier)
          end

          it 'does not include PII in the no-PII file' do
            first_names_in(no_pii_xml).should == ['', '']
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

      describe 'with directly provided instances' do
        before do
          options[:content] = [
            create_person('XQ9', :first_name => 'Xavier'),
            create_person('QX4', :first_name => 'Quentin'),
            create_instance(participant_model, :p_id => 'P_QX9')
          ]
        end

        it 'contains the specified records' do
          xml.xpath('//person').size.should == 2
          xml.xpath('//participant').size.should == 1
        end

        it 'contains the records in the provided order' do
          xml.xpath('//person/person_id').collect { |e| e.text.strip }.should == %w(XQ9 QX4)
        end
      end
    end

    describe 'the generated ZIP file', :slow do
      let(:expected_zipfile) { Pathname.new(filename.to_s + '.zip') }
      let(:options) { {} }

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
      subject { XmlEmitter.new(spec_config, nil, options).filename }
      let(:options) { { } }

      before do
        pending "ncs_mdes doesn't work on JRuby" if RUBY_PLATFORM == 'java'

        # Need an actual PSU ID for the default filename code to work
        NcsNavigator.configuration.psus.first.id = '20000216'

        # Time.parse uses Time.now internally, so this needs to be
        # defined before starting to register the mock.
        t = Time.parse('2011-07-28')
        Time.stub!(:now).and_return(t)
      end

      it 'is county_name-DATE.xml' do
        subject.to_s.should == 'bear_lake-20110728.xml'
      end

      it 'is county_name-DATE-PII.xml when PII is included' do
        options[:'include-pii'] = true
        subject.to_s.should == 'bear_lake-20110728-PII.xml'
      end

      it 'is a Pathname' do
        subject.should be_a Pathname
      end
    end

    describe 'generating PII XML in parallel' do
      let(:emitter) { XmlEmitter.new(spec_config, provided_filename, options) }
      let(:options) { { :'and-pii' => true } }
      let(:provided_filename) { 'emitted.xml' }

      let(:xml_files) { emitter.xml_files }
      let(:pii_xml_file) { emitter.xml_files.find { |xf| xf.include_pii? } }
      let(:no_pii_xml_file) { emitter.xml_files.find { |xf| !xf.include_pii? } }

      describe 'filenames' do
        describe 'when none specified', :slow, :use_mdes do
          let(:provided_filename) { nil }

          before do
            NcsNavigator.configuration.psus.first.id = '20000216'

            # Time.parse uses Time.now internally, so this needs to be
            # defined before starting to register the mock.
            t = Time.parse('2011-07-28')
            Time.stub!(:now).and_return(t)
          end

          it 'uses the normal one for the non-PII variant' do
            no_pii_xml_file.filename.to_s.should == 'bear_lake-20110728.xml'
          end

          it 'uses the -PII variant for the one with PII' do
            pii_xml_file.filename.to_s.should == 'bear_lake-20110728-PII.xml'
          end

          describe 'but a directory is specified' do
            before do
              options[:directory] = '/baz/zap'
            end

            it 'includes the directory in the with-PII name' do
              pii_xml_file.filename.to_s.should == '/baz/zap/bear_lake-20110728-PII.xml'
            end

            it 'includes the directory in the without-PII name' do
              no_pii_xml_file.filename.to_s.should == '/baz/zap/bear_lake-20110728.xml'
            end
          end
        end

        describe 'when one is specified' do
          let(:provided_filename) { 'emitted.xml' }

          it 'uses the specified name for the non-PII variant' do
            no_pii_xml_file.filename.to_s.should == 'emitted.xml'
          end

          it 'it adds a -PII infix before the extension for the PII variant' do
            pii_xml_file.filename.to_s.should == 'emitted-PII.xml'
          end
        end
      end

      it 'produces two files' do
        emitter.xml_files.size.should == 2
      end

      it 'produces a with-PII file' do
        pii_xml_file.should_not be_nil
      end

      it 'produces a without-PII file' do
        no_pii_xml_file.should_not be_nil
      end
    end
  end
end
