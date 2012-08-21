require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  class ForeignKeyIndex
    ##
    # An existing key provider for {ForeignKeyIndex} that uses a statically
    # configured hash of keys.
    class StaticKeyProvider
      attr_accessor :known_keys

      def initialize(known_keys={})
        @known_keys = known_keys
      end

      def existing_keys(model_class)
        # validation is to help with the uses of this class in specs
        fail 'model_class must be a string' unless Class === model_class
        known_keys[model_class.to_s]
      end
    end
  end
end
