require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers::MdesCsv
  ##
  # An enumerable that joins the results for several {TableReaders} into a single
  # {#each} call.
  class MultipleTableReader
    include Enumerable

    attr_reader :configuration, :table_readers

    ##
    # @param [Configuration] configuration
    # @param [Array<TableReader>] the table readers to concatenate
    def initialize(configuration, table_readers)
      @configuration = configuration
      @table_readers = table_readers.sort_by { |r| configuration.models_module.mdes_order.index(r.model) }
    end

    def each
      table_readers.each do |reader|
        reader.each do |record|
          yield record
        end
      end
    end

    def name
      table_readers.collect(&:name).join(', ')
    end
  end
end
