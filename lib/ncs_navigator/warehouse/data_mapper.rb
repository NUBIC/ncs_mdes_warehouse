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

    ##
    # DataMapper `:string` that's an {NcsType}.
    class NcsString < ::DataMapper::Property::String
      include NcsType
    end

    ##
    # DataMapper `:text` that's an {NcsType}.
    class NcsText < ::DataMapper::Property::Text
      include NcsType
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
