require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointOne
  class FourteenMthAsqSaq
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'fourteen_mth_asq_saq'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :fourteen_mth_asq_saq_id,
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
    belongs_to :asq14_address,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Address',
               :child_key => [ :asq14_address_id ], :required => false
    property   :asq14_address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq14_address_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq14_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :asq14_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :asq14_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :asq14_zip,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :asq14_zip4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    property   :asq14_country,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..50 }
    belongs_to :home_phone,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Telephone',
               :child_key => [ :home_phone_id ], :required => false
    property   :home_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :other_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    belongs_to :email,
               'NcsNavigator::Warehouse::Models::ThreePointOne::Email',
               :child_key => [ :email_id ], :required => false
    property   :email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :asq14_assistname_comment,
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
    property   :asq14_age_months,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :asq14_age_days,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :asq14_adj_age_months,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :asq14_adj_age_days,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :comm14_3words_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm14_point_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm14_shake_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm14_pat_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm14_four_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm14_find_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :comm14_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :grmtr14_2hands_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr14_1hand_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr14_sevsteps_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr14_climbblock_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr14_bndstd_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr14_walk_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :grmtr14_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :fnmtr14_pickcrumb_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr14_throw_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr14_lfturn_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr14_stack_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr14_mark_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr14_threestk_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :fnmtr14_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :pslv14_kpcopy_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv14_drop2_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv14_scrcopy_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv14_drcrumb_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv14_drop_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv14_rchtool_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :pslv14_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :psoc14_lift_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc14_throw_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc14_hugtoy_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc14_spoon_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc14_undress_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc14_attn_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "5", "10", "-1", "-2", "-4"] }
    property   :psoc14_total,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }

    mdes_order :psu_id, :fourteen_mth_asq_saq_id, :recruit_type, :du_id, :p_id, :r_p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :asq_date_comp, :c_fname, :c_minitial, :c_lname, :child_dob, :weeks_premature, :child_sex, :respondent_fname, :respondent_minitial, :respondent_lname, :respondent_rel, :respondent_rel_oth, :asq14_address_id, :asq14_address_1, :asq14_address_2, :asq14_unit, :asq14_city, :asq14_state, :asq14_zip, :asq14_zip4, :asq14_country, :home_phone_id, :home_phone, :other_phone, :email_id, :email, :asq14_assistname_comment, :asq_child_id, :sc_id, :sc_name, :asq14_age_months, :asq14_age_days, :asq14_adj_age_months, :asq14_adj_age_days, :comm14_3words_1, :comm14_point_2, :comm14_shake_3, :comm14_pat_4, :comm14_four_5, :comm14_find_6, :comm14_total, :grmtr14_2hands_1, :grmtr14_1hand_2, :grmtr14_sevsteps_3, :grmtr14_climbblock_4, :grmtr14_bndstd_5, :grmtr14_walk_6, :grmtr14_total, :fnmtr14_pickcrumb_1, :fnmtr14_throw_2, :fnmtr14_lfturn_3, :fnmtr14_stack_4, :fnmtr14_mark_5, :fnmtr14_threestk_6, :fnmtr14_total, :pslv14_kpcopy_1, :pslv14_drop2_2, :pslv14_scrcopy_3, :pslv14_drcrumb_4, :pslv14_drop_5, :pslv14_rchtool_6, :pslv14_total, :psoc14_lift_1, :psoc14_throw_2, :psoc14_hugtoy_3, :psoc14_spoon_4, :psoc14_undress_5, :psoc14_attn_6, :psoc14_total

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointOne
