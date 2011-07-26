require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  module DataMapper
    module NcsType
      def self.included(into)
        into.class_eval do
          accept_options :pii
          attr_reader :pii
        end
      end

      def initialize(model, name, options = {})
        super
        @pii = options[:pii]
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
