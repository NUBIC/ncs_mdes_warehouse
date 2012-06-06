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
  # This filter is stateless and should be configured without
  # instantiation.
  class CodedAsMissingFilter
    MISSING_CODES = %w(-3 -4 -6 -7)

    class << self
      def call(records)
        records.collect { |r| process(r) }.compact
      end

      private

      def process(record)
        return nil if MISSING_CODES.include?(record.key.first)

        remove_missing_foreign_keys(record)
        remove_missing_noncoded_values(record)

        record
      end

      def remove_missing_foreign_keys(record)
        record.class.relationships.each do |rel|
          reference_key = rel.child_key.first.name
          reference_value = record.send(reference_key)
          next unless reference_value
          if MISSING_CODES.include?(reference_value) || reference_value.strip.empty?
            record.send("#{reference_key}=", nil)
          end
        end
      end

      def remove_missing_noncoded_values(record)
        record.class.properties.each do |prop|
          unless prop.required? || prop.options[:set]
            prop_value = record.send(prop.name)
            if MISSING_CODES.include?(prop_value)
              record.send("#{prop.name}=", nil)
            end
          end
        end
      end
    end
  end
end
