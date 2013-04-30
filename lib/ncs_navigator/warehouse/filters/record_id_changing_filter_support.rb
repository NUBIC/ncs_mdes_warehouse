require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Filters
  ##
  # A framework for a filter which modifies all ID values for a particular
  # record type. The class into which it is mixed must implement `changed_id`,
  # a method which takes an incoming ID value and provides the replacement
  # value.
  module RecordIdChangingFilterSupport
    ##
    # @return [Class] the warehouse model for which the ID will be prefixed.
    attr_reader :model

    ##
    # An inheritable constructor for filters which mix in this module.
    #
    # @param [Configuration] configuration the warehouse configuration
    # @param [Hash] options
    # @option options [String,Symbol] :table the name of the table for the
    #   target record type.
    # @option options [String,Symbol] :model the unqualified name of the
    #   warehouse model for the target record type. If both this and `:table`
    #   are specified, `:table` wins.
    def initialize(configuration, options={})
      @model =
        if options[:table]
          configuration.model(options[:table])
        elsif options[:model]
          configuration.model(options[:model])
        else
          fail 'Please specify either :table or :model.'
        end
      unless self.respond_to?(:changed_id)
        fail "#{self.class} does not implement changed_id"
      end
    end

    ##
    # Modifies all IDs for the target record type according to the
    # consumer-defined `changed_id` method.
    #
    # @param [Array<MdesModel>] records the records to review and modify
    # @return [Array<MdesModel>] the same records.
    #   Any IDs will be updated in place.
    def call(records)
      records.each do |rec|
        if rec.is_a?(model)
          change_primary_key(rec)
          # see the class comment on {CompositeFilter}
          rec.instance_eval { remove_instance_variable(:@_key) if defined?(@_key) }
        end
        change_foreign_keys_if_any(rec)
      end
    end

    def change_primary_key(record)
      key_name = model.key.first.name
      record[key_name] = changed_id(record[key_name])
    end
    protected :change_primary_key

    def change_foreign_keys_if_any(record)
      record.class.relationships.each do |rel|
        next unless rel.parent_model == model
        foreign_key = rel.child_key.first.name
        record[foreign_key] = changed_id(record[foreign_key])
      end
    end
    protected :change_foreign_keys_if_any
  end
end
