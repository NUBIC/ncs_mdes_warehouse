require 'data_mapper'
require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  module DataMapper
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

    class NcsString < ::DataMapper::Property::String
      include NcsType
    end

    class NcsText < ::DataMapper::Property::Text
      include NcsType
    end

    class NcsInteger < ::DataMapper::Property::Integer
      include NcsType
    end

    class NcsDecimal < ::DataMapper::Property::Decimal
      include NcsType
    end
  end
end
