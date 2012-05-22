require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # The namespace for post-ETL hook implementations which are provided
  # with the warehouse.
  #
  # A post-ETL hook is an object which responds to either
  # `etl_succeeded` or `etl_failed` (or both). Each method takes a
  # single hash argument which, when the method is called, will
  # contain the following keys:
  #
  # * `:transform_statuses` the list of {TransformStatus}es describing
  #   the ETL process that was just completed
  # * `:configuration` a reference to the warehouse {Configuration}.
  #
  # @see Configuration#add_post_etl_hook
  module Hooks
    autoload :EtlStatusEmail, 'ncs_navigator/warehouse/hooks/etl_status_email'
  end
end
