require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  module MdesCsv
    autoload :MultipleTableReader, 'ncs_navigator/warehouse/transformers/mdes_csv/multiple_table_reader'
    autoload :TableReader,         'ncs_navigator/warehouse/transformers/mdes_csv/table_reader'

    ##
    # Creates a transformer that loads a directory full of CSV files,
    # interpreting each of them using {TableReader}. Files that do not have  the
    # extension `csv` are ignored; so are subdirectories.
    #
    # @return [#transform]
    def self.from_directory(configuration, directory, options={})
      readers = Dir["#{directory}/*.csv"].collect do |csv_file|
        model = File.basename(csv_file).sub(/\.csv$/, '')
        MdesCsv::TableReader.new(configuration, model, csv_file)
      end

      EnumTransformer.new(
        configuration,
        MdesCsv::MultipleTableReader.new(configuration, readers),
        options)
    end
  end
end
