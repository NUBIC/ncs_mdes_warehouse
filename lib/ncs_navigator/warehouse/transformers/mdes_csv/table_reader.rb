require 'ncs_navigator/warehouse'

require 'csv'

module NcsNavigator::Warehouse::Transformers::MdesCsv
  ##
  # A streaming reader for a CSV containing one table's-worth of MDES data.
  #
  # The CSV is converted into warehouse model instances, one record per row. The
  # CSV MUST have a header row whose cells indicate the variable contained in
  # each column.
  class TableReader
    include Enumerable

    attr_reader :configuration, :model, :filename

    ##
    # @param [Configuration] configuration
    # @param [Class,#to_s] model_designator a name for the expected record type
    #   from the current CSV. It can be a table name or unqualified warehouse
    #   model name, or an actual warehouse model class.
    # @param [String] filename the file containing the CSV
    def initialize(configuration, model_designator, filename)
      @configuration = configuration
      @model =
        if Class === model_designator
          model_designator
        else
          configuration.model(model_designator.to_s)
        end
      @filename = filename
    end

    def name
      "#{filename} => #{model.mdes_table_name} table"
    end

    def each
      CSV.foreach(filename, :headers => true, :header_converters => [:downcase]) do |row|
        yield create_instance_for_row(row)
      end
    end

    protected

    def create_instance_for_row(row)
      model.new.tap do |instance|
        row.each do |header, value|
          next if header == 'transaction_type'

          setter = "#{header}="
          unless instance.respond_to?(setter)
            fail "Unknown attribute #{header.inspect} for #{model}."
          end
          instance.send(setter, value)
        end

        unless instance.key && instance.key.first
          fail "Missing key (#{model.key.first.name}) for #{model}."
        end
      end
    end
  end
end
