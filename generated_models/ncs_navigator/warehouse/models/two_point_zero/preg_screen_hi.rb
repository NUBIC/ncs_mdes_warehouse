require 'data_mapper'
require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Models::TwoPointZero
  class PregScreenHi
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'preg_screen_hi'

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :ps_hi_id,
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
    property   :incoming,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :time_stamp_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :r_gender,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-6", "-3", "-4"] }
    property   :male_r,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :female_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :first_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :r_phone_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :time_stamp_3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :r_fname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :r_lname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :person_dob,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :age,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :age_range,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "-1", "-2", "-3", "-4"] }
    property   :age_elig,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-6", "-3", "-4"] }
    property   :time_stamp_4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    belongs_to :address,
               'NcsNavigator::Warehouse::Models::TwoPointZero::Address',
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
    property   :du_elig_confirm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-4"] }
    property   :time_stamp_5,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :know_ncs,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :how_know_ncs_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :elig,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :time_stamp_6,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :pregnant,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :orig_due_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :date_period,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :weeks_preg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :month_preg,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :trimester,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_7,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :trying,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-1", "-2", "-3", "-4"] }
    property   :hyster,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :ovaries,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :tubes_tied,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :menopause,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :med_unable,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :med_unable_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :time_stamp_8,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :maristat,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-1", "-2", "-3", "-4"] }
    property   :educ,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-1", "-2", "-3", "-4"] }
    property   :employ,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "-5", "-1", "-2", "-3", "-4"] }
    property   :employ_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :ethnicity,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :race_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :person_lang,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "-5", "-1", "-2", "-3", "-4"] }
    property   :person_lang_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :time_stamp_9,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :hh_members,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :num_child,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :income_4cat,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-1", "-2", "-3", "-4"] }
    property   :time_stamp_10,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :phone_nbr,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :phone_nbr_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :phone_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "-5", "-1", "-2", "-3", "-4"] }
    property   :phone_type_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :home_phone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
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
    property   :same_addr,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    belongs_to :mail_address,
               'NcsNavigator::Warehouse::Models::TwoPointZero::Address',
               :child_key => [ :mail_address_id ], :required => false
    property   :mail_address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :mail_address_2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :mail_unit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..10 }
    property   :mail_city,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..50 }
    property   :mail_state,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :pii => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "-1", "-2", "-3", "-4"] }
    property   :mail_zip,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..5 }
    property   :mail_zip4,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..4 }
    property   :have_email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-3", "-4"] }
    property   :email,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :email_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "-1", "-2", "-3", "-4"] }
    property   :email_share,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-3", "-4"] }
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
               'NcsNavigator::Warehouse::Models::TwoPointZero::Address',
               :child_key => [ :new_address_id ], :required => false
    property   :new_address_1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..100 }
    property   :new_address_2,
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
    property   :time_stamp_11,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :ppg_first,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-4"] }
    property   :time_stamp_12,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :other_female,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :time_stamp_13,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }
    property   :english,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-4"] }
    property   :contact_lang,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "-5", "-3", "-4"] }
    property   :contact_lang_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :interpret,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-3", "-4"] }
    property   :contact_interpret,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-3", "-4"] }
    property   :contact_interpret_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :time_stamp_14,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..19, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9])?$/ }

    mdes_order :psu_id, :ps_hi_id, :recruit_type, :du_id, :p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :time_stamp_1, :incoming, :time_stamp_2, :r_gender, :male_r, :female_1, :first_name, :r_phone_1, :time_stamp_3, :r_fname, :r_lname, :person_dob, :age, :age_range, :age_elig, :time_stamp_4, :address_id, :address_1, :address_2, :unit, :city, :state, :zip, :zip4, :du_elig_confirm, :time_stamp_5, :know_ncs, :how_know_ncs_oth, :elig, :time_stamp_6, :pregnant, :orig_due_date, :date_period, :weeks_preg, :month_preg, :trimester, :time_stamp_7, :trying, :hyster, :ovaries, :tubes_tied, :menopause, :med_unable, :med_unable_oth, :time_stamp_8, :maristat, :educ, :employ, :employ_oth, :ethnicity, :race_oth, :person_lang, :person_lang_oth, :time_stamp_9, :hh_members, :num_child, :income_4cat, :time_stamp_10, :phone_nbr, :phone_nbr_oth, :phone_type, :phone_type_oth, :home_phone, :cell_phone_1, :cell_phone_2, :cell_phone_3, :cell_phone_4, :cell_phone, :same_addr, :mail_address_id, :mail_address_1, :mail_address_2, :mail_unit, :mail_city, :mail_state, :mail_zip, :mail_zip4, :have_email, :email, :email_type, :email_share, :plan_move, :where_move, :move_info, :new_address_id, :new_address_1, :new_address_2, :new_unit, :new_city, :new_state, :new_zip, :new_zip4, :when_move, :date_move, :time_stamp_11, :ppg_first, :time_stamp_12, :other_female, :time_stamp_13, :english, :contact_lang, :contact_lang_oth, :interpret, :contact_interpret, :contact_interpret_oth, :time_stamp_14

  end # class
end # module NcsNavigator::Warehouse::Models::TwoPointZero
