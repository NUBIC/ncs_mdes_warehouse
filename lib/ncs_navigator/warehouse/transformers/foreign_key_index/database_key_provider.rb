require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  class ForeignKeyIndex
    ##
    # Provides existing key lists out of the configured DataMapper "working"
    # repo.
    class DatabaseKeyProvider
      def existing_keys(model_class)
        ::DataMapper.repository(:mdes_warehouse_working).adapter.select(
          "SELECT #{model_class.key.first.name} FROM #{model_class.mdes_table_name}"
        )
      end
    end
  end
end
