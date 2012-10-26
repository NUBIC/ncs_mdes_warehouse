require 'spec_helper'

module NcsNavigator::Warehouse::Transformers::MdesCsv
  describe TableReader, :use_mdes do
    let(:model_designator) { 'person' }
    let(:filename) { tmpdir + 'people.csv' }
    let(:reader) { TableReader.new(spec_config, model_designator, filename) }

    it 'is enumerable' do
      TableReader.ancestors.should include(Enumerable)
    end

    describe '#initialize' do
      describe 'model_designator parameter' do
        it 'accepts a table name to find the model' do
          TableReader.new(spec_config, 'address', filename).model.
            should == spec_config.model(:Address)
        end

        it 'accepts a model name to find the model' do
          TableReader.new(spec_config, 'Telephone', filename).model.
            should == spec_config.model(:Telephone)
        end

        it 'accepts a model class directly' do
          TableReader.new(spec_config, spec_config.model(:Telephone), filename).model.
            should == spec_config.model(:Telephone)
        end
      end
    end

    describe '#name' do
      it 'is the filename and table name' do
        reader.name.should == "#{filename} => person table"
      end
    end

    describe '#each' do
      let(:records) { reader.to_a }
      let(:first_record) { records.first }

      def csv_file(row_arrays)
        File.open(filename, 'w') do |f|
          row_arrays.each do |row_array|
            f.puts row_array.join(',')
          end
        end
      end

      it 'produces one record per line' do
        csv_file [
          %w(person_id),
          %w(A3),
          %w(B7),
          %w(C8)
        ]

        records.collect { |rec| rec.person_id }.should == %w(A3 B7 C8)
      end

      it 'maps record attributes via the headers' do
        csv_file [
          %w(last_name first_name person_id),
          %w(MacMurray Fred FM36)
        ]

        first_record.person_id.should == 'FM36'
        first_record.first_name.should == 'Fred'
        first_record.last_name.should == 'MacMurray'
      end

      it 'produces model instances' do
        csv_file [
          %w(last_name first_name person_id),
          %w(MacMurray Fred FM36)
        ]

        first_record.should be_a spec_config.model('person')
      end

      it 'interprets headers case-insensitively' do
        csv_file [
          %w(PERSON_ID FiRST_NaMe),
          %w(BS34 Barbara)
        ]

        first_record.first_name.should == 'Barbara'
      end

      it 'fails for an unknown attribute' do
        csv_file [
          %w(person_id helicopter_model),
          %w(TR900 Huey)
        ]

        expect { records }.to raise_error(/Unknown attribute "helicopter_model" for NcsNavigator::Warehouse::Models::\w+::Person\./)
      end

      it 'ignores transaction_type' do
        csv_file [
          %w(person_id transaction_type),
          %w(TR900 NA)
        ]

        expect { records }.to_not raise_error
      end

      it 'fails if the key is not provided' do
        csv_file [
          %w(first_name last_name),
          %w(Medford Man)
        ]

        expect { records }.to raise_error(/Missing key \(person_id\) for NcsNavigator::Warehouse::Models::\w+::Person\./)
      end
    end
  end
end
