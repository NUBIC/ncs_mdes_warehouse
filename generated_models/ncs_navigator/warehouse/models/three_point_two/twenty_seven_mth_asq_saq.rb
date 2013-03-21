require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointTwo
  class TwentySevenMthAsqSaq
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'twenty_seven_mth_asq_saq'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :twenty_seven_mth_asq_saq_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :recruit_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-4"] }
    belongs_to :du,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::DwellingUnit',
               :child_key => [ :du_id ], :required => false
    belongs_to :p,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Participant',
               :child_key => [ :p_id ], :required => true
    belongs_to :r_p,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Participant',
               :child_key => [ :r_p_id ], :required => false
    belongs_to :event,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Event',
               :child_key => [ :event_id ], :required => true
    property   :event_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "-5", "-4"] }
    property   :event_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    belongs_to :instrument,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Instrument',
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
    property   :asq_date_comp,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :c_fname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :c_minitial,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..2 }
    property   :c_lname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :child_dob,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :child_sex,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :respondent_fname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :respondent_minitial,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..2 }
    property   :respondent_lname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :respondent_rel,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-4"] }
    property   :respondent_rel_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    belongs_to :asq27_address,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Address',
               :child_key => [ :asq27_address_id ], :required => false
    property   :asq27_address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq27_address_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq27_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :asq27_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :asq27_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :asq27_zip,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :asq27_zip4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    property   :asq27_country,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..50 }
    belongs_to :home_phone_record,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Telephone',
               :child_key => [ :home_phone_id ], :required => false
    property   :home_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :other_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    belongs_to :email_record,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Email',
               :child_key => [ :email_id ], :required => false
    property   :email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq27_assistname_comment,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq_child_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..36 }
    property   :sc_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000013", "20000015", "20000019", "20000022", "20000024", "20000026", "20000029", "20000031", "20000033", "20000036", "20000038", "20000041", "20000043", "20000047", "20000049", "20000051", "20000053", "20000056", "20000059", "20000061", "20000064", "20000066", "20000068", "20000071", "20000073", "20000074", "20000075", "20000076", "20000077", "20000078", "20000080", "20000081", "20000082", "20000120", "20000121", "20000122", "-4", "20000000"] }
    property   :sc_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..100 }
    property   :comm27_direct_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm27_name_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm27_7bodypt_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm27_usewords_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm27_4words_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :explwrds27_comment,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :comm27_dircorrect_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm27_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :grmtr27_steps_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr27_run_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr27_jump_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr27_cankick_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr27_3inch_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr27_1foot_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr27_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :fnmtr27_knobs_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr27_switch_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr27_vertical_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr27_7stack_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr27_string_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr27_horizontal_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr27_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :pslv27_pretend_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv27_away_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv27_ptself_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv27_stdon_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv27_line4_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv27_person_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :example27_comment2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :pslv27_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :psoc27_gestures_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc27_fork_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc27_playdoll_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc27_pushtoy_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc27_calli_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc27_dress_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc27_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }

    mdes_order :psu_id, :twenty_seven_mth_asq_saq_id, :recruit_type, :du_id, :p_id, :r_p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :asq_date_comp, :c_fname, :c_minitial, :c_lname, :child_dob, :child_sex, :respondent_fname, :respondent_minitial, :respondent_lname, :respondent_rel, :respondent_rel_oth, :asq27_address_id, :asq27_address_1, :asq27_address_2, :asq27_unit, :asq27_city, :asq27_state, :asq27_zip, :asq27_zip4, :asq27_country, :home_phone_id, :home_phone, :other_phone, :email_id, :email, :asq27_assistname_comment, :asq_child_id, :sc_id, :sc_name, :comm27_direct_1, :comm27_name_2, :comm27_7bodypt_3, :comm27_usewords_4, :comm27_4words_5, :explwrds27_comment, :comm27_dircorrect_6, :comm27_total, :grmtr27_steps_1, :grmtr27_run_2, :grmtr27_jump_3, :grmtr27_cankick_4, :grmtr27_3inch_5, :grmtr27_1foot_6, :grmtr27_total, :fnmtr27_knobs_1, :fnmtr27_switch_2, :fnmtr27_vertical_3, :fnmtr27_7stack_4, :fnmtr27_string_5, :fnmtr27_horizontal_6, :fnmtr27_total, :pslv27_pretend_1, :pslv27_away_2, :pslv27_ptself_3, :pslv27_stdon_4, :pslv27_line4_5, :pslv27_person_6, :example27_comment2, :pslv27_total, :psoc27_gestures_1, :psoc27_fork_2, :psoc27_playdoll_3, :psoc27_pushtoy_4, :psoc27_calli_5, :psoc27_dress_6, :psoc27_total

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointTwo
