require 'spec_helper'

module NcsNavigator::Warehouse::Transformers::MdesCsv
  describe MultipleTableReader do
    def table_reader(model)
      TableReader.new(spec_config, model, csv_filename(model))
    end

    def csv_filename(model_name)
      tmpdir + "#{model_name}.csv"
    end

    def csv_file(model_name, row_arrays)
      File.open(csv_filename(model_name), 'w') do |f|
        row_arrays.each do |row_array|
          f.puts row_array.join(',')
        end
      end
    end

    let(:table_readers) {
      [
        table_reader('LinkPersonParticipant'),
        table_reader('Person'),
        table_reader('Participant')
      ]
    }

    let(:reader) {
      MultipleTableReader.new(spec_config, table_readers)
    }

    let(:sub_enums) { reader.table_readers }

    it 'is Enumerable' do
      MultipleTableReader.ancestors.should include(Enumerable)
    end

    describe '#initialize' do
      it 'orders the sub-enums by MDES order' do
        sub_enums.collect { |table_reader| table_reader.model.mdes_table_name }.
          should == %w(person participant link_person_participant)
      end
    end

    describe '#each' do
      it 'yields the results from each table reader in order' do
        csv_file 'Participant', [
          %w(p_id), %w(X90)
        ]

        csv_file 'Person', [
          %w(person_id), %w(P34)
        ]

        csv_file 'LinkPersonParticipant', [
          %w(person_pid_id), %w(T23)
        ]

        reader.to_a.collect { |rec| [rec.class.mdes_table_name, rec.key.first] }.should == [
          %w(person P34), %w(participant X90), %w(link_person_participant T23)
        ]
      end
    end
  end
end
