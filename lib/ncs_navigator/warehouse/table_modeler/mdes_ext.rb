require 'active_support/core_ext/string'
require 'active_support/ordered_hash'

module NcsNavigator
  ##
  # Extensions to the models provided by the ncs_mdes gem to assist in
  # model generation.
  module Mdes
    ##
    # Extends ActiveSupport's OrderedHash to produce an inspection
    # which is valid ruby and which preserves the order.
    #
    # @private
    class OrderedHash < ActiveSupport::OrderedHash
      def inspect
        '{ ' << keys.collect { |k| "#{k.inspect} => #{self[k].inspect}" }.join(', ') << ' }'
      end
    end

    class TransmissionTable
      def wh_model_name(module_name=nil)
        [module_name, name.camelize].compact.join('::')
      end

      def wh_variables
        variables.reject { |v| v.name == 'transaction_type' }
      end

      def wh_keys
        @wh_keys ||=
          begin
            pks = variables.select { |v| v.type.name == 'primaryKeyType' }
            if !pks.empty?
              pks
            elsif name == 'study_center'
              variables.select { |v| v.name == 'sc_id' }
            elsif name == 'psu'
              variables.select { |v| v.name == 'psu_id' }
            else
              fail "Could not determine key to use for #{name} table"
            end
          end
      end

      def wh_manual_validations
        variables.collect do |v|
          v.wh_manual_validations
        end.flatten
      end
    end

    class Variable
      def wh_property_options(in_table)
        @wh_property_options ||=
          begin
            options = OrderedHash.new
            if in_table.wh_keys.include?(self)
              options[:key] = true
            end
            options[:required] = true if required
            options[:omittable] = true if omittable
            options[:pii] = pii unless pii.blank?
            options.merge(type.wh_type_options)
          end
      end

      def wh_manual_validations
        [
          # Other combinations of length restrictions are handled with
          # autovalidations
          if type.min_length && !type.max_length
            "validates_length_of :#{name}, :minimum => #{type.min_length}"
          end
        ].compact
      end

      def wh_reference_name
        fail 'Does not apply' unless self.table_reference
        if self.name =~ /_id$/
          self.name.sub(/_id$/, '')
        else
          self.name + '_record'
        end
      end
    end

    class VariableType
      def wh_type_options
        @wh_type_options ||=
          begin
            options = OrderedHash.new
            options[:length] = (wh_min_length..wh_max_length) if wh_max_length
            options[:set] = code_list.collect(&:value) if code_list
            options[:format] = pattern if pattern

            if wh_property_type == NcsNavigator::Warehouse::DataMapper::NcsDecimal
              # While PostgreSQL supports arbitrary precision DECIMALs,
              # DataMapper doesn't. However PostgreSQL uses flexible
              # storage for DECIMALs, so a larger-than-ever-needed
              # precision should be fine.
              options[:precision] = 128
              options[:scale] = 64
            end

            options
          end
      end

      def wh_max_length
        @wh_max_length ||=
          case
          when max_length
            max_length
          when code_list
            code_list.collect { |c| c.value.size }.max
          end
      end

      def wh_min_length
        @wh_min_length ||=
          case
          when min_length
            min_length
          when code_list
            code_list.collect { |c| c.value.size }.min
          else
            0
          end
      end

      def wh_property_type
        @wh_property_type ||=
          case base_type
          when :string
            if code_list || pattern || (wh_max_length && wh_max_length < 1000)
              NcsNavigator::Warehouse::DataMapper::NcsString
            else
              NcsNavigator::Warehouse::DataMapper::NcsText
            end
          when :int
            NcsNavigator::Warehouse::DataMapper::NcsInteger
          when :decimal
            NcsNavigator::Warehouse::DataMapper::NcsDecimal
          else
            fail "Unsupported base_type #{base_type.inspect}"
          end
      end
    end
  end
end
