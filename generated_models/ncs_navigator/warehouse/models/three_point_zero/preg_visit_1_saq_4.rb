require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointZero
  class PregVisit1Saq_4
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'preg_visit_1_saq_4'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :pv1_saq_4_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :recruit_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-4"] }
    belongs_to :du,
               'NcsNavigator::Warehouse::Models::ThreePointZero::DwellingUnit',
               :child_key => [ :du_id ], :required => false
    belongs_to :p,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Participant',
               :child_key => [ :p_id ], :required => true
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
    property   :planned,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :month_try,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :wanted,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :timing,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-2", "-3", "-4"] }
    property   :f_f_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :f_l_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :father_same_hh,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :father_know_preg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :contact_f_now,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :contact_f_later,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    belongs_to :f_addr,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Address',
               :child_key => [ :f_addr_id ], :required => false
    property   :f_addr1_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :f_addr2_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :f_unit_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :f_city_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :f_state_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :f_zipcode_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :f_zip4_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    belongs_to :f_phone_record,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Telephone',
               :child_key => [ :f_phone_id ], :required => false
    property   :f_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :f_age,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :past_preg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :num_preg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :age_first,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :num_preg_subpreg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :premature,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :miscarry,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cig_past,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cig_past_freq,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-2", "-3", "-4"] }
    property   :cig_past_num,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :cig_now,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :cig_now_freq,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-2", "-3", "-4"] }
    property   :cig_now_num,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :drink_past,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-2", "-4"] }
    property   :drink_past_num,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :drink_past_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-2", "-3", "-4"] }
    property   :drink_now,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-2", "-4"] }
    property   :drink_now_num,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :drink_now_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-2", "-3", "-4"] }
    property   :learn,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :help,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :incent,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :research,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :envir,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :community,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :know_others,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :family,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :doctor,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :staff,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :opin_spouse,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-3", "-4"] }
    property   :opin_family,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-3", "-4"] }
    property   :opin_friend,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-3", "-4"] }
    property   :opin_dr,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-3", "-4"] }
    property   :experience,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-3", "-4"] }
    property   :improve,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-3", "-4"] }
    property   :int_length,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-3", "-4"] }
    property   :int_stress,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-3", "-4"] }
    property   :int_repeat,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }

    mdes_order :psu_id, :pv1_saq_4_id, :recruit_type, :du_id, :p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :planned, :month_try, :wanted, :timing, :f_f_name, :f_l_name, :father_same_hh, :father_know_preg, :contact_f_now, :contact_f_later, :f_addr_id, :f_addr1_2, :f_addr2_2, :f_unit_2, :f_city_2, :f_state_2, :f_zipcode_2, :f_zip4_2, :f_phone_id, :f_phone, :f_age, :past_preg, :num_preg, :age_first, :num_preg_subpreg, :premature, :miscarry, :cig_past, :cig_past_freq, :cig_past_num, :cig_now, :cig_now_freq, :cig_now_num, :drink_past, :drink_past_num, :drink_past_5, :drink_now, :drink_now_num, :drink_now_5, :learn, :help, :incent, :research, :envir, :community, :know_others, :family, :doctor, :staff, :opin_spouse, :opin_family, :opin_friend, :opin_dr, :experience, :improve, :int_length, :int_stress, :int_repeat

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointZero
