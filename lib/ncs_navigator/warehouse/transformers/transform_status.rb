require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  ##
  # Tracks and stores the progress of a particular transform.
  class TransformStatus
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def errors
      @errors ||= []
    end

    def unsuccessful_record(record, message)
      errors << Error.new(record.class, message)
    end

    class Error < Struct.new(:model_class, :message); end
  end
end
