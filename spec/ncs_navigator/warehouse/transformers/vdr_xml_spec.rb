require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe VdrXml do
    let(:config) { NcsNavigator::Warehouse::Configuration.new }
    let(:options) { { :filters => lambda { |x| x } } }

    shared_examples 'a VDR transformer' do
      it 'returns a transformer' do
        subject.should respond_to(:transform)
      end

      it 'uses a VDR reader as the enumerable' do
        subject.enum.should be_a VdrXml::Reader
      end

      it 'passes the options to the transformer' do
        subject.filters.to_a.size.should == 1
      end
    end

    describe '.from_file' do
      let(:path) { File.expand_path('../vdr_xml/made_up_vdr_xml.xml', __FILE__) }
      subject { VdrXml.from_file(config, path, options) }

      it 'uses the given filename' do
        subject.enum.filename.should == path
      end

      include_examples 'a VDR transformer'
    end

    describe '.from_most_recent_file' do
      let(:path) { tmpdir('contractor-files') }
      subject { VdrXml.from_most_recent_file(config, list_or_glob, options) }

      before do
        system("touch -t 02030405 '#{path}/a'")
        system("touch -t 02040405 '#{path}/b'")
        system("touch -t 02020405 '#{path}/c'")
      end

      describe 'with a file list' do
        let(:list_or_glob) { Dir[File.join(path, '*')] }

        it 'uses the most recent filename from the list' do
          subject.enum.filename.should == File.join(path, 'b')
        end

        include_examples 'a VDR transformer'

        describe 'that is empty' do
          let(:list_or_glob) { [] }

          it 'fails' do
            lambda { subject }.should raise_error /The file list is empty./
          end
        end
      end

      describe 'with a glob' do
        let(:list_or_glob) { File.join(path, '*') }

        it 'uses the most recent filename matched by the glob' do
          subject.enum.filename.should == File.join(path, 'b')
        end

        include_examples 'a VDR transformer'

        describe 'when the glob does not match anything' do
          let(:list_or_glob) { File.join(path, 'z*') }

          it 'fails' do
            lambda { subject }.should raise_error %r{Glob .*?./z\* does not match any files}
          end
        end
      end
    end
  end
end
