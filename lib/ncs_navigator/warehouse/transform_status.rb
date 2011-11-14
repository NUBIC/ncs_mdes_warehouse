require 'ncs_navigator/warehouse'

require 'data_mapper'

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
    def self.memory_only(name)
      TransformStatus.new(:name => name).tap do |s|
        def s.transform_errors
          @transform_errors ||= []
        end
      end
    end

    storage_names[:default] = storage_names[:mdes_warehouse_working] =
      storage_names[:mdes_warehouse_reporting] = 'wh_transform_status'

    property :id,           Serial
    property :name,         String,  :required => true, :length => 255
    property :start_time,   DateTime
    property :end_time,     DateTime
    property :record_count, Integer, :default => 0

    has n, :transform_errors, 'NcsNavigator::Warehouse::TransformError'

    def add_error(message)
      self.transform_errors << TransformError.new(:message => message)
    end

    def unsuccessful_record(record, message)
      self.transform_errors <<
        TransformError.new(:model_class => record.class.name, :message => message)
    end
  end

  class TransformError
    include ::DataMapper::Resource

    storage_names[:default] = storage_names[:mdes_warehouse_working] =
      storage_names[:mdes_warehouse_reporting] = 'wh_transform_error'

    property :id,          Serial
    property :message,     Text,   :required => true
    property :model_class, String, :length => 255

    belongs_to :transform_status, TransformStatus, :required => true
  end

  TransformError.finalize
  TransformStatus.finalize
end
