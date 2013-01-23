require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointZero
  class TracingInt
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'tracing_int'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :tracing_int_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :recruit_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-4"] }
    belongs_to :du,
               'NcsNavigator::Warehouse::Models::ThreePointZero::DwellingUnit',
               :child_key => [ :du_id ], :required => false
    belongs_to :hh,
               'NcsNavigator::Warehouse::Models::ThreePointZero::HouseholdUnit',
               :child_key => [ :hh_id ], :required => true
    belongs_to :p,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Participant',
               :child_key => [ :p_id ], :required => false
    belongs_to :r_p,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Participant',
               :child_key => [ :r_p_id ], :required => false
    belongs_to :event,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Event',
               :child_key => [ :event_id ], :required => true
    property   :event_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "-5", "-4"] }
    property   :event_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    belongs_to :instrument,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Instrument',
               :child_key => [ :instrument_id ], :required => true
    property   :instrument_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "-5", "-4"] }
    property   :instrument_version,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..6 }
    property   :instrument_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :time_stamp_tr_st,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    belongs_to :address,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Address',
               :child_key => [ :address_id ], :required => false
    property   :address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :address_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :zip,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :zip4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    property   :plan_move,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :where_move,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :move_info,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    belongs_to :new_address,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Address',
               :child_key => [ :new_address_id ], :required => false
    property   :new_address1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :new_address2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :new_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :new_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :new_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :new_zip,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :new_zip4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    property   :when_move,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :date_move,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..7, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9])?$/ }
    property   :home_phone_confirm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-7", "-3", "-4"] }
    belongs_to :home_phone_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :home_phone_id ], :required => false
    property   :home_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :cell_phone_confirm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-7", "-3", "-4"] }
    belongs_to :cell_phone_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :cell_phone_id ], :required => false
    property   :cell_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :cell_phone_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cell_phone_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cell_phone_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :email_confirm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-7", "-3", "-4"] }
    belongs_to :email_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Email',
               :child_key => [ :email_id ], :required => false
    property   :email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :email_appt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :email_quest,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :comm_contact,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :contact_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-7", "-3", "-4"] }
    property   :contact_frnd,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :contact_fname_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :contact_lname_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :contact_relate_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_relate1_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    belongs_to :c_addr1,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Address',
               :child_key => [ :c_addr1_id ], :required => false
    property   :c_addr1_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_addr2_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_unit_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :c_city_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :c_state_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :c_zipcode_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :c_zip4_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    belongs_to :contact_phone,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :contact_phone_id ], :required => false
    property   :contact_phone_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :contact_phone1_type_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_phone1_type_1_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :contact_other_ph_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    belongs_to :contact_phone_2_1_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :contact_phone_2_1_id ], :required => false
    property   :contact_phone_2_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :contact_phone2_type_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_phone2_type_1_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :contact_fname_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :contact_lname_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :contact_relate_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_relate2_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    belongs_to :c_addr2,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Address',
               :child_key => [ :c_addr2_id ], :required => false
    property   :c_addr1_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_addr_2_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_unit_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :c_city_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :c_state_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :c_zipcode_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :c_zip4_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    belongs_to :contact_phone_2_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :contact_phone_2_id ], :required => false
    property   :contact_phone_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :contact_phone1_type_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_phone1_type_2_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :contact_other_ph_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    belongs_to :contact_phone_2_2_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :contact_phone_2_2_id ], :required => false
    property   :contact_phone_2_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :contact_phone2_type_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_phone2_type_2_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :contact_fname_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :contact_lname_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :contact_relate_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_relate3_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    belongs_to :c_addr3,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Address',
               :child_key => [ :c_addr3_id ], :required => false
    property   :c_addr1_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_addr_2_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_unit_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :c_city_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :c_state_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :c_zipcode_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :c_zip4_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    belongs_to :contact_phone_3_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :contact_phone_3_id ], :required => false
    property   :contact_phone_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :contact_phone1_type_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_phone1_type_3_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :contact_other_ph_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    belongs_to :contact_phone_2_3_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :contact_phone_2_3_id ], :required => false
    property   :contact_phone_2_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :contact_phone2_type_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :contact_phone2_type_3_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :prev_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :city_prev1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :state_prev1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :city_prev2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :state_prev2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :city_prev3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :state_prev3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :dr_license_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :dr_license_num,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..20 }
    property   :time_stamp_tr_et,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }

    mdes_order :psu_id, :tracing_int_id, :recruit_type, :du_id, :hh_id, :p_id, :r_p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :time_stamp_tr_st, :address_id, :address_1, :address_2, :unit, :city, :state, :zip, :zip4, :plan_move, :where_move, :move_info, :new_address_id, :new_address1, :new_address2, :new_unit, :new_city, :new_state, :new_zip, :new_zip4, :when_move, :date_move, :home_phone_confirm, :home_phone_id, :home_phone, :cell_phone_confirm, :cell_phone_id, :cell_phone, :cell_phone_2, :cell_phone_3, :cell_phone_4, :email_confirm, :email_id, :email, :email_appt, :email_quest, :comm_contact, :contact_1, :contact_frnd, :contact_fname_1, :contact_lname_1, :contact_relate_1, :contact_relate1_oth, :c_addr1_id, :c_addr1_1, :c_addr2_1, :c_unit_1, :c_city_1, :c_state_1, :c_zipcode_1, :c_zip4_1, :contact_phone_id, :contact_phone_1, :contact_phone1_type_1, :contact_phone1_type_1_oth, :contact_other_ph_1, :contact_phone_2_1_id, :contact_phone_2_1, :contact_phone2_type_1, :contact_phone2_type_1_oth, :contact_fname_2, :contact_lname_2, :contact_relate_2, :contact_relate2_oth, :c_addr2_id, :c_addr1_2, :c_addr_2_2, :c_unit_2, :c_city_2, :c_state_2, :c_zipcode_2, :c_zip4_2, :contact_phone_2_id, :contact_phone_2, :contact_phone1_type_2, :contact_phone1_type_2_oth, :contact_other_ph_2, :contact_phone_2_2_id, :contact_phone_2_2, :contact_phone2_type_2, :contact_phone2_type_2_oth, :contact_fname_3, :contact_lname_3, :contact_relate_3, :contact_relate3_oth, :c_addr3_id, :c_addr1_3, :c_addr_2_3, :c_unit_3, :c_city_3, :c_state_3, :c_zipcode_3, :c_zip4_3, :contact_phone_3_id, :contact_phone_3, :contact_phone1_type_3, :contact_phone1_type_3_oth, :contact_other_ph_3, :contact_phone_2_3_id, :contact_phone_2_3, :contact_phone2_type_3, :contact_phone2_type_3_oth, :prev_city, :city_prev1, :state_prev1, :city_prev2, :state_prev2, :city_prev3, :state_prev3, :dr_license_state, :dr_license_num, :time_stamp_tr_et

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointZero
