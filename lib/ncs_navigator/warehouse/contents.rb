require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # Provides an Enumerable over all of the content for some or all of the
  # tables in a warehouse instance. Provides streaming results over batches
  # for large content sets.
  class Contents
    include Enumerable

    ##
    # @return [Array<Class>] the warehouse models whose records will be enumerated
    #   by this instance.
    attr_reader :models

    ##
    # @return [CompositeFilter] the filters in use on this transformer.
    attr_reader :filters

    ##
    # @return [Numeric] the maximum number of records to load into memory before
    #   yielding them to the consumer.
    attr_reader :block_size

    ##
    # Create a new {Contents}.
    #
    # @param [Configuration] config the configuration for the
    #   warehouse from which to iterate over records.
    #
    # @option options [Array<#call>,#call] :filters a list of
    #   filters to use for this transformer
    # @option options [Fixnum] :block-size (5000) the maximum number
    #   of records to load into memory before yielding them to the consumer.
    #   Reduce this to reduce the memory load of the emitter. Increasing it
    #   will probably not improve performance, even if you have sufficient
    #   memory to load more records.
    # @option options [Array<#to_s>] :tables (all for current MDES
    #   version) the tables to include in the iteration.
    def initialize(config, options={})
      @configuration = config
      @record_count = 0
      @block_size = options[:'block-size'] || 5000

      @models =
        if options[:tables]
          options[:tables].collect { |t| t.to_s }.collect { |t|
            config.models_module.mdes_order.find { |model| model.mdes_table_name == t }
          }
        else
          config.models_module.mdes_order
        end

      filter_list = options[:filters]
      @filters = NcsNavigator::Warehouse::Filters::CompositeFilter.new(
        filter_list ? [*filter_list].compact : [])
    end

    ##
    # Yields each instance of every configured {model #models} in turn.
    def each
      models.each do |model|
        key = model.key.first.name.to_sym
        count = model.count
        offset = 0
        while offset < count
          model.all(:limit => block_size, :offset => offset, :order => key.asc).each do |instance|
            filters.call([instance]).each do |filtered_record|
              yield filtered_record
            end
          end
          offset += block_size
        end
      end
    end
  end
end
