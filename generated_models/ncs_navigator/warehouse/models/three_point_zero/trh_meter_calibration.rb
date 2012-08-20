require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointZero
  class TrhMeterCalibration
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'trh_meter_calibration'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    belongs_to :srsc,
               'NcsNavigator::Warehouse::Models::ThreePointZero::SrscInfo',
               :child_key => [ :srsc_id ], :required => true
    belongs_to :equip,
               'NcsNavigator::Warehouse::Models::ThreePointZero::SpecEquipment',
               :child_key => [ :equip_id ], :required => true
    belongs_to :staff,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Staff',
               :child_key => [ :staff_id ], :required => true
    property   :calibration_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :calibration_expire_dt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :verification_dt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :thr_equip_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..36 }
    property   :precision_term_temp,
               NcsNavigator::Warehouse::DataMapper::NcsDecimal,
               { :required => true, :precision => 128, :scale => 64 }
    property   :trh_temp,
               NcsNavigator::Warehouse::DataMapper::NcsDecimal,
               { :required => true, :precision => 128, :scale => 64 }
    property   :salts_moist,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-7", "-4"] }
    property   :s_33rh_reading,
               NcsNavigator::Warehouse::DataMapper::NcsDecimal,
               { :required => true, :precision => 128, :scale => 64 }
    property   :s_75rh_reading,
               NcsNavigator::Warehouse::DataMapper::NcsDecimal,
               { :required => true, :precision => 128, :scale => 64 }
    property   :s_33_rh_need_calib,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-7", "-4"] }
    property   :s_75_rh_need_calib,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-7", "-4"] }
    property   :s_33rh_reading_calib,
               NcsNavigator::Warehouse::DataMapper::NcsDecimal,
               { :required => true, :precision => 128, :scale => 64 }
    property   :s_75rh_reading_calib,
               NcsNavigator::Warehouse::DataMapper::NcsDecimal,
               { :required => true, :precision => 128, :scale => 64 }
    property   :trh_calib_fail_rsn,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-5", "-2", "-7", "-4"] }
    property   :trh_calib_fail_reas_other,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :trh_calib_status,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-4"] }

    mdes_order :psu_id, :srsc_id, :equip_id, :staff_id, :calibration_id, :calibration_expire_dt, :verification_dt, :thr_equip_id, :precision_term_temp, :trh_temp, :salts_moist, :s_33rh_reading, :s_75rh_reading, :s_33_rh_need_calib, :s_75_rh_need_calib, :s_33rh_reading_calib, :s_75rh_reading_calib, :trh_calib_fail_rsn, :trh_calib_fail_reas_other, :trh_calib_status

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointZero