require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Filters
  ##
  # A {CompositeFilter filter} which adds a prefix to the ID for every record of
  # a given type. This filter is stateful and so must be instantiated.
  class AddIdPrefixFilter
    include RecordIdChangingFilterSupport

    ##
    # Creates the filter.
    #
    # In addition to the options specified here, this constructor accepts the
    # options defined on {RecordIdChangingFilterSupport#initialize}.
    #
    # @param [Configuration] configuration the warehouse configuration.
    # @param [Hash] options
    #
    # @option options [String] :prefix the prefix to apply.
    def initialize(configuration, options={})
      super
      @prefix = options[:prefix] or fail 'Please specify a :prefix.'
    end

    ##
    # @param [String] original_id the incoming ID.
    # @return [String] the ID with the prefix applied.
    def changed_id(original_id)
      "#{@prefix}#{original_id}" if original_id
    end
  end
end
