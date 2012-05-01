require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # The namespace for post-ETL hook implementations which are provided
  # with the warehouse.
  #
  # A post-ETL hook is an object which responds to either
  # `etl_succeeded` or `etl_failed` (or both). Each method takes one
  # argument: the list of {TransformStatus}es describing the ETL
  # process that was just completed.
  #
  # @see Configuration#add_post_etl_hook
  module PostEtlHooks
  end
end
