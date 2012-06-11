require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  ##
  # Some source data sets include unnecessary placeholder records and
  # values. This filter excludes the following variables and records:
  #
  # * Entire records whose ID is one of the common MDES error codes
  #   (-3, -4, -6, -7).
  #
  # * Foreign key values whose ID is one of those same MDES error
  #   codes.
  #
  # * Variable values which are not required and not coded whose value
  #   is one of these error codes (e.g., a comments field whose value
  #   is '-7').
  #
  # If the `:additional_codes` option is passed to the constructor,
  # those codes will be used in addition to the default list (i.e.,
  # -3, -4, -6, -7).
  #
  # This filter may be used with or without instantiation.
  class CodedAsMissingFilter
    DEFAULT_MISSING_CODES = %w(-3 -4 -6 -7)

    class << self
      def call(records)
        singleton.call(records)
      end

      private

      def singleton
        @singleton ||= CodedAsMissingFilter.new
      end
    end

    attr_reader :missing_codes

    ##
    # @param configuration [Configuration]
    # @param options [Hash<Symbol, Object>]
    # @option options [Array<String>] :additional_codes a list of
    #   other codes (beyond the defaults) which will also be treated
    #   as "missing" for the purposes of this filter.
    def initialize(configuration=nil, options={})
      @missing_codes = DEFAULT_MISSING_CODES.dup
      if options[:additional_codes]
        @missing_codes += options[:additional_codes]
      end
    end

    def call(records)
      records.collect { |r| process(r) }.compact
    end

    private

    def process(record)
      return nil if missing_codes.include?(record.key.first)

      remove_missing_foreign_keys(record)
      remove_missing_noncoded_values(record)

      record
    end

    def remove_missing_foreign_keys(record)
      record.class.relationships.each do |rel|
        reference_key = rel.child_key.first.name
        reference_value = record.send(reference_key)

        if reference_value && missing_codes.include?(reference_value)
          record.send("#{reference_key}=", nil)
        end
      end
    end

    def remove_missing_noncoded_values(record)
      record.class.properties.each do |prop|
        unless prop.required? || prop.options[:set]
          prop_value = record.send(prop.name)
          if missing_codes.include?(prop_value)
            record.send("#{prop.name}=", nil)
          end
        end
      end
    end

  end
end
