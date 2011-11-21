require 'data_mapper'
require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # DataMapper extensions for the warehouse.
  module DataMapper
    ##
    # Adds the `pii` and `omittable` attributes to property types that
    # are derived from the MDES.
    module NcsType
      def self.included(into)
        into.class_eval do
          accept_options :pii, :omittable
          attr_reader :pii, :omittable
        end
      end

      def initialize(model, name, options = {})
        super
        @pii = options[:pii]
        @omittable = options[:omittable]
      end
    end

    module NcsStringType
      protected

      def self.included(into)
        into.class_eval do
          alias :original_typecast_to_primitive :typecast_to_primitive

          def typecast_to_primitive(value)
            if value.is_a?(BigDecimal)
              value.to_s('F')
            else
              original_typecast_to_primitive(value)
            end
          end
        end
      end
    end

    ##
    # DataMapper `:string` that's an {NcsType}.
    class NcsString < ::DataMapper::Property::String
      include NcsType
      include NcsStringType
    end

    ##
    # DataMapper `:text` that's an {NcsType}.
    class NcsText < ::DataMapper::Property::Text
      include NcsType
      include NcsStringType
    end

    ##
    # DataMapper `:integer` that's an {NcsType}.
    class NcsInteger < ::DataMapper::Property::Integer
      include NcsType
    end

    ##
    # DataMapper `:decimal` that's an {NcsType}.
    class NcsDecimal < ::DataMapper::Property::Decimal
      include NcsType
    end
  end
end
