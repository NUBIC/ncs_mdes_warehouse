require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe MdesCsv, :use_mdes do
    let(:options) { { :filters => lambda { |x| x } } }

    shared_examples 'an MDES CSV transformer' do
      it 'returns a transformer' do
        transformer.should respond_to(:transform)
      end

      it 'passes the options to the transformer' do
        transformer.filters.to_a.size.should == 1
      end
    end

    describe '.from_directory' do
      let(:dir) { tmpdir('mdes_csv') }
      let(:transformer) { MdesCsv.from_directory(spec_config, dir.to_s, options) }

      before do
        %w(
          person.csv
          contact.csv
          event.csv
          readme.txt
        ).each do |fn|
          FileUtils.touch(dir + fn)
        end
      end

      include_examples 'an MDES CSV transformer'

      it 'uses a MultipleTableReader' do
        transformer.enum.should be_a(MdesCsv::MultipleTableReader)
      end

      it 'uses all the *.csv files in the directory' do
        transformer.enum.table_readers.collect(&:filename).should == [
          (dir + 'person.csv').to_s,
          (dir + 'event.csv').to_s,
          (dir + 'contact.csv').to_s
        ]
      end

      it 'uses the file name (sans ext) as the model designator' do
        transformer.enum.table_readers.collect(&:model).should == [
          spec_config.model('person'),
          spec_config.model('event'),
          spec_config.model('contact'),
        ]
      end
    end
  end
end
