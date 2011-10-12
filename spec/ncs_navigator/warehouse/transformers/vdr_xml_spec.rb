require File.expand_path('../../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::Transformers
  describe VdrXml do
    let(:config) { NcsNavigator::Warehouse::Configuration.new }

    shared_examples 'a VDR transformer' do
      it 'returns a transformer' do
        subject.should respond_to(:transform)
      end

      it 'uses a VDR reader as the enumerable' do
        subject.enum.should be_a VdrXml::Reader
      end
    end

    describe '.from_file' do
      let(:path) { File.expand_path('../vdr_xml/made_up_vdr_xml.xml', __FILE__) }
      subject { VdrXml.from_file(config, path) }

      it 'uses the given filename' do
        subject.enum.filename.should == path
      end

      include_examples 'a VDR transformer'
    end

    describe '.from_most_recent_file' do
      let(:path) { tmpdir('contractor-files') }
      subject { VdrXml.from_most_recent_file(config, Dir[File.join(path, '*')]) }

      before do
        system("touch -t 02030405 '#{path}/a'")
        system("touch -t 02040405 '#{path}/b'")
        system("touch -t 02020405 '#{path}/c'")
      end

      it 'uses the most recent filename from the list' do
        subject.enum.filename.should == File.join(path, 'b')
      end

      include_examples 'a VDR transformer'
    end
  end
end
