require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::TwoPointZero
  class PregVisit22
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'preg_visit_2_2'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :pv2_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :recruit_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-4"] }
    belongs_to :du,
               'NcsNavigator::Warehouse::Models::TwoPointZero::DwellingUnit',
               :child_key => [ :du_id ], :required => false
    belongs_to :p,
               'NcsNavigator::Warehouse::Models::TwoPointZero::Participant',
               :child_key => [ :p_id ], :required => true
    belongs_to :event,
               'NcsNavigator::Warehouse::Models::TwoPointZero::Event',
               :child_key => [ :event_id ], :required => true
    property   :event_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "-5", "-4"] }
    property   :event_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    belongs_to :instrument,
               'NcsNavigator::Warehouse::Models::TwoPointZero::Instrument',
               :child_key => [ :instrument_id ], :required => true
    property   :instrument_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "-5", "-4"] }
    property   :instrument_version,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..36 }
    property   :instrument_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :time_stamp_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :name_confirm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :r_fname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :r_lname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :dob_confirm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :person_dob,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :age_elig,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-4"] }
    property   :time_stamp_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :pregnant,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :loss_info,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :due_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :date_known,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :bplan_change,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :birth_plan,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-2", "-3", "-4"] }
    property   :birth_place,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    belongs_to :b_address,
               'NcsNavigator::Warehouse::Models::TwoPointZero::Address',
               :child_key => [ :b_address_id ], :required => false
    property   :b_address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :b_address_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :b_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :b_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :b_zipcode,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :use_pr_log,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :reason_no_pr_log,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-2", "-3", "-4"] }
    property   :reason_no_pr_log_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :num_prov_pr_log,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :num_prov_rec,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :date_visit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :diabetes_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :highbp_preg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :urine,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :preeclamp,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :early_labor,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :anemia,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :nausea,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :kidney,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :rh_disease,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :group_b,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :herpes,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :vaginosis,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :oth_condition,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :condition_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :time_stamp_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :hospital,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :admin_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :hosp_nights,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :diagnose,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :recent_move,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :own_home,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-5", "-1", "-2", "-3", "-4"] }
    property   :own_home_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :age_home,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :length_reside,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :length_reside_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-3", "-4"] }
    property   :main_heat,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "-5", "-1", "-2", "-3", "-4"] }
    property   :main_heat_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :cooling,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :water_drink,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-5", "-1", "-2", "-3", "-4"] }
    property   :water_drink_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :water_cook,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-5", "-1", "-2", "-3", "-4"] }
    property   :water_cook_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :time_stamp_7,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :water,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :mold,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_8,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :prenovate2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :pdecorate2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_9,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :working,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :hours,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :shift_work,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_10,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :listen,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :advice,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :affection,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :daily_help,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :emot_support,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :amt_support,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_11,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :insure,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ins_employ,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ins_medicaid,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ins_tricare,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ins_ihs,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ins_medicare,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ins_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_12,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :comm_email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    property   :have_email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :email_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :email_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :comm_cell,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    property   :cell_phone_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cell_phone_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cell_phone_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cell_phone_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :cell_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :time_stamp_13,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :comm_contact,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    property   :contact_1,
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
               'NcsNavigator::Warehouse::Models::TwoPointZero::Address',
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
    property   :contact_phone_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
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
               'NcsNavigator::Warehouse::Models::TwoPointZero::Address',
               :child_key => [ :c_addr2_id ], :required => false
    property   :c_addr1_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :c_addr2_2,
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
    property   :contact_phone_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :time_stamp_14,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }

    mdes_order :psu_id, :pv2_id, :recruit_type, :du_id, :p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :time_stamp_1, :name_confirm, :r_fname, :r_lname, :dob_confirm, :person_dob, :age_elig, :time_stamp_2, :pregnant, :time_stamp_3, :loss_info, :due_date, :date_known, :bplan_change, :birth_plan, :birth_place, :b_address_id, :b_address_1, :b_address_2, :b_city, :b_state, :b_zipcode, :use_pr_log, :reason_no_pr_log, :reason_no_pr_log_oth, :num_prov_pr_log, :num_prov_rec, :date_visit, :diabetes_1, :highbp_preg, :urine, :preeclamp, :early_labor, :anemia, :nausea, :kidney, :rh_disease, :group_b, :herpes, :vaginosis, :oth_condition, :condition_oth, :time_stamp_4, :hospital, :admin_date, :hosp_nights, :diagnose, :time_stamp_5, :recent_move, :own_home, :own_home_oth, :age_home, :length_reside, :length_reside_unit, :main_heat, :main_heat_oth, :cooling, :time_stamp_6, :water_drink, :water_drink_oth, :water_cook, :water_cook_oth, :time_stamp_7, :water, :mold, :time_stamp_8, :prenovate2, :pdecorate2, :time_stamp_9, :working, :hours, :shift_work, :time_stamp_10, :listen, :advice, :affection, :daily_help, :emot_support, :amt_support, :time_stamp_11, :insure, :ins_employ, :ins_medicaid, :ins_tricare, :ins_ihs, :ins_medicare, :ins_oth, :time_stamp_12, :comm_email, :have_email, :email_2, :email_3, :email, :comm_cell, :cell_phone_1, :cell_phone_2, :cell_phone_3, :cell_phone_4, :cell_phone, :time_stamp_13, :comm_contact, :contact_1, :contact_fname_1, :contact_lname_1, :contact_relate_1, :contact_relate1_oth, :c_addr1_id, :c_addr1_1, :c_addr2_1, :c_unit_1, :c_city_1, :c_state_1, :c_zipcode_1, :c_zip4_1, :contact_phone_1, :contact_fname_2, :contact_lname_2, :contact_relate_2, :contact_relate2_oth, :c_addr2_id, :c_addr1_2, :c_addr2_2, :c_unit_2, :c_city_2, :c_state_2, :c_zipcode_2, :c_zip4_2, :contact_phone_2, :time_stamp_14

  end # class
end # module NcsNavigator::Warehouse::Models::TwoPointZero
