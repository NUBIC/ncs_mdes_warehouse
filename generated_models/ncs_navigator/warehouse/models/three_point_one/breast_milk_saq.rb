require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointOne
  class BreastMilkSaq
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'breast_milk_saq'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :breast_milk_saq_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :recruit_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-4"] }
    belongs_to :du,
               'NcsNavigator::Warehouse::Models::ThreePointOne::DwellingUnit',
               :child_key => [ :du_id ], :required => false
    belongs_to :p,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Participant',
               :child_key => [ :p_id ], :required => true
    belongs_to :r_p,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Participant',
               :child_key => [ :r_p_id ], :required => false
    belongs_to :event,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Event',
               :child_key => [ :event_id ], :required => true
    property   :event_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "-5", "-4"] }
    property   :event_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    belongs_to :instrument,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Instrument',
               :child_key => [ :instrument_id ], :required => true
    property   :instrument_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "-5", "-4"] }
    property   :instrument_version,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..6 }
    property   :instrument_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :p_bmq_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :p_bmq_time,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..5, :format => /^([0-9][0-9]:[0-9][0-9])?$/ }
    property   :p_bmq_time_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-4"] }
    property   :p_bmq_how_long,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-4"] }
    property   :p_bmq_last_feed,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-4"] }
    property   :p_bmq_pump,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :p_bmq_type_pump,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :p_bmq_brand_pump,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-2", "-4"] }
    property   :p_bmq_brand_pump_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :p_bmq_empty,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :p_bmq_caffeine,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :p_bmq_alcohol,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :p_bmq_prsc_otc_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_7,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_8,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_9,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_prsc_otc_10,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..100 }
    property   :p_bmq_freezer,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-4", "-7"] }
    property   :specimen_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..36 }

    mdes_order :psu_id, :breast_milk_saq_id, :recruit_type, :du_id, :p_id, :r_p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :p_bmq_date, :p_bmq_time, :p_bmq_time_unit, :p_bmq_how_long, :p_bmq_last_feed, :p_bmq_pump, :p_bmq_type_pump, :p_bmq_brand_pump, :p_bmq_brand_pump_oth, :p_bmq_empty, :p_bmq_caffeine, :p_bmq_alcohol, :p_bmq_prsc_otc_1, :p_bmq_prsc_otc_2, :p_bmq_prsc_otc_3, :p_bmq_prsc_otc_4, :p_bmq_prsc_otc_5, :p_bmq_prsc_otc_6, :p_bmq_prsc_otc_7, :p_bmq_prsc_otc_8, :p_bmq_prsc_otc_9, :p_bmq_prsc_otc_10, :p_bmq_freezer, :specimen_id

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointOne
