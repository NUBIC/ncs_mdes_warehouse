require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointThree
  class Organization
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'organization'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :organization_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :organization_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..100 }
    property   :company_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..100 }
    property   :collection_start_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :collection_end_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :org_contract_no,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..50 }

    mdes_order :organization_id, :organization_name, :company_name, :collection_start_date, :collection_end_date, :org_contract_no

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointThree
