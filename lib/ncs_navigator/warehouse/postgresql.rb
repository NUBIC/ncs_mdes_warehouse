require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  module PostgreSQL
    autoload :Pgpass, 'ncs_navigator/warehouse/postgresql/pgpass'
  end
end
