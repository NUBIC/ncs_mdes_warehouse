require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointThree
  class Outreach
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'outreach'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    belongs_to :tsu,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Tsu',
               :child_key => [ :tsu_id ], :required => false
    belongs_to :ssu,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Ssu',
               :child_key => [ :ssu_id ], :required => false
    property   :outreach_event_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :outreach_event_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :outreach_target,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :omittable => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "-5", "-4"] }
    property   :outreach_target_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :omittable => true, :pii => :possible, :length => 0..255 }
    property   :outreach_mode,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "-5", "-4"] }
    property   :outreach_mode_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :outreach_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "-5", "-4"] }
    property   :outreach_type_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :outreach_tailored,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-4"] }
    property   :outreach_lang1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-4"] }
    property   :outreach_lang2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :omittable => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "-1", "-5", "-6", "-4"] }
    property   :outreach_lang_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :outreach_race1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-3", "-4"] }
    property   :outreach_race2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :omittable => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-7", "-4"] }
    property   :outreach_race_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :omittable => true, :pii => :possible, :length => 0..255 }
    property   :outreach_culture1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-3", "-4"] }
    property   :outreach_culture2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "-5", "-7", "-4"] }
    property   :outreach_culture_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :outreach_quantity,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :outreach_cost,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }
    property   :outreach_staffing,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :outreach_incident,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-4"] }
    belongs_to :incident,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Incident',
               :child_key => [ :incident_id ], :required => false
    property   :outreach_eval_result,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-4"] }

    mdes_order :psu_id, :tsu_id, :ssu_id, :outreach_event_id, :outreach_event_date, :outreach_target, :outreach_target_oth, :outreach_mode, :outreach_mode_oth, :outreach_type, :outreach_type_oth, :outreach_tailored, :outreach_lang1, :outreach_lang2, :outreach_lang_oth, :outreach_race1, :outreach_race2, :outreach_race_oth, :outreach_culture1, :outreach_culture2, :outreach_culture_oth, :outreach_quantity, :outreach_cost, :outreach_staffing, :outreach_incident, :incident_id, :outreach_eval_result

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointThree
