require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointTwo
  class SixteenMthAsqSaq
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'sixteen_mth_asq_saq'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :sixteen_mth_asq_saq_id,
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
    property   :weeks_premature,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
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
    belongs_to :asq16_address,
               'NcsNavigator::Warehouse::Models::ThreePointTwo::Address',
               :child_key => [ :asq16_address_id ], :required => false
    property   :asq16_address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq16_address_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq16_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :asq16_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :asq16_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :asq16_zip,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :asq16_zip4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    property   :asq16_country,
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
    property   :asq16_assistname_comment,
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
    property   :asq16_age_months,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :asq16_age_days,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :asq16_adj_age_months,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :asq16_adj_age_days,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :comm16_pat_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm16_four_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm16_points_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm16_find_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm16_imitate_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm16_eight_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm16_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :grmtr16_sevsteps_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr16_climbblock_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr16_bndstd_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr16_walk_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr16_nofall_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr16_climb_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr16_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :fnmtr16_lfturn_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr16_throw_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr16_stack_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr16_threestk_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr16_mark_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr16_turn_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr16_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :pslv16_scrcopy_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv16_drcrumb_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv16_drop_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv16_rchtool_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv16_scribble_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv16_dmpbtl_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv16_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :psoc16_spoon_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc16_undress_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc16_hugtoy_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc16_mirror_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc16_attn_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc16_help_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc16_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }

    mdes_order :psu_id, :sixteen_mth_asq_saq_id, :recruit_type, :du_id, :p_id, :r_p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :asq_date_comp, :c_fname, :c_minitial, :c_lname, :child_dob, :weeks_premature, :child_sex, :respondent_fname, :respondent_minitial, :respondent_lname, :respondent_rel, :respondent_rel_oth, :asq16_address_id, :asq16_address_1, :asq16_address_2, :asq16_unit, :asq16_city, :asq16_state, :asq16_zip, :asq16_zip4, :asq16_country, :home_phone_id, :home_phone, :other_phone, :email_id, :email, :asq16_assistname_comment, :asq_child_id, :sc_id, :sc_name, :asq16_age_months, :asq16_age_days, :asq16_adj_age_months, :asq16_adj_age_days, :comm16_pat_1, :comm16_four_2, :comm16_points_3, :comm16_find_4, :comm16_imitate_5, :comm16_eight_6, :comm16_total, :grmtr16_sevsteps_1, :grmtr16_climbblock_2, :grmtr16_bndstd_3, :grmtr16_walk_4, :grmtr16_nofall_5, :grmtr16_climb_6, :grmtr16_total, :fnmtr16_lfturn_1, :fnmtr16_throw_2, :fnmtr16_stack_3, :fnmtr16_threestk_4, :fnmtr16_mark_5, :fnmtr16_turn_6, :fnmtr16_total, :pslv16_scrcopy_1, :pslv16_drcrumb_2, :pslv16_drop_3, :pslv16_rchtool_4, :pslv16_scribble_5, :pslv16_dmpbtl_6, :pslv16_total, :psoc16_spoon_1, :psoc16_undress_2, :psoc16_hugtoy_3, :psoc16_mirror_4, :psoc16_attn_5, :psoc16_help_6, :psoc16_total

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointTwo
