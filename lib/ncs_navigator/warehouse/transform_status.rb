require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse
  ##
  # Tracks and stores the progress of a particular transform.
  class TransformStatus
    include ::DataMapper::Resource

    ##
    # DataMapper 1.2 attempts to query for associations, even if the
    # record has never been saved. This fails if the database
    # connection is not set up (as in most of this library's
    # tests). This method creates a new instance which works around
    # this problem, at the cost of the instances not being accurately
    # persistable.
    def self.memory_only(name, attrs={})
      TransformStatus.new(attrs.merge(:name => name)).tap do |s|
        def s.transform_errors
          @transform_errors ||= []
        end
      end
    end

    storage_names[:default] = storage_names[:mdes_warehouse_working] =
      storage_names[:mdes_warehouse_reporting] = 'wh_transform_status'

    property :id,           Serial
    property :name,         Text,    :required => true
    property :start_time,   DateTime
    property :end_time,     DateTime
    property :record_count, Integer, :default => 0
    property :position,     Integer

    has n, :transform_errors, 'NcsNavigator::Warehouse::TransformError'

    def add_error(message)
      self.transform_errors << TransformError.new(:message => message)
    end

    def unsuccessful_record(record, message)
      self.transform_errors <<
        TransformError.new(
          :model_class => record.class.name,
          :record_id => (record.key.first if record && record.key),
          :message => message)
    end
  end

  class TransformError
    include ::DataMapper::Resource

    storage_names[:default] = storage_names[:mdes_warehouse_working] =
      storage_names[:mdes_warehouse_reporting] = 'wh_transform_error'

    property :id,          Serial
    property :message,     Text,   :required => true
    property :model_class, String, :length => 255
    property :record_id,   String, :length => 255

    belongs_to :transform_status, TransformStatus, :required => true

    def self.for_exception(exception, context_message=nil)
      TransformError.new(:message => [
          context_message,
          "#{exception.class}: #{exception}",
          StringifyTrace.stringify_trace(exception.backtrace)
        ].compact.join("\n")
      )
    end
  end

  TransformError.finalize
  TransformStatus.finalize
end
