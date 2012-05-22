require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::TwoPointTwo
  class SpecStorage
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'spec_storage'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    belongs_to :spsc,
               'NcsNavigator::Warehouse::Models::TwoPointTwo::SpecSpscInfo',
               :child_key => [ :spsc_id ], :required => true
    property   :storage_container_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :placed_in_storage_dt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..16, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9])?$/ }
    belongs_to :staff,
               'NcsNavigator::Warehouse::Models::TwoPointTwo::Staff',
               :child_key => [ :staff_id ], :required => true
    belongs_to :equip,
               'NcsNavigator::Warehouse::Models::TwoPointTwo::SpecEquipment',
               :child_key => [ :equip_id ], :required => false
    property   :master_storage_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-4"] }
    property   :storage_comment,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :storage_comment_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :removed_from_storage,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :removed_from_storage_dt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..16, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9])?$/ }
    property   :temp_event_st,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :temp_event_et,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :temp_event_low_temp,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }
    property   :temp_event_high_temp,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }

    mdes_order :psu_id, :spsc_id, :storage_container_id, :placed_in_storage_dt, :staff_id, :equip_id, :master_storage_unit, :storage_comment, :storage_comment_oth, :removed_from_storage, :removed_from_storage_dt, :temp_event_st, :temp_event_et, :temp_event_low_temp, :temp_event_high_temp

  end # class
end # module NcsNavigator::Warehouse::Models::TwoPointTwo
