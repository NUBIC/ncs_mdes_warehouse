require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointThree
  class BsiSaq
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'bsi_saq'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :bsi_saq_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :recruit_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-4"] }
    belongs_to :du,
               'NcsNavigator::Warehouse::Models::ThreePointThree::DwellingUnit',
               :child_key => [ :du_id ], :required => false
    belongs_to :p,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Participant',
               :child_key => [ :p_id ], :required => true
    belongs_to :r_p,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Participant',
               :child_key => [ :r_p_id ], :required => false
    belongs_to :event,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Event',
               :child_key => [ :event_id ], :required => true
    property   :event_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "-5", "-4"] }
    property   :event_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    belongs_to :instrument,
               'NcsNavigator::Warehouse::Models::ThreePointThree::Instrument',
               :child_key => [ :instrument_id ], :required => true
    property   :instrument_type,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "-5", "-4"] }
    property   :instrument_version,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..6 }
    property   :instrument_repeat_key,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :bsi_nervous,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_faintness,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_control_thoughts,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_blame_others,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_memory_trouble,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_annoy_easy,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_chest_pain,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_afraid_streets,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_suicide_thoughts,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_no_trust,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_no_appetite,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_scared,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_temper_outburst,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_lonely_people,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_blocked,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_lonely,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_blue,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_no_interest,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_fearful,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_easily_hurt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_people_unfriendly,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_inferior,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_nausea,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_watched,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_trouble_sleep,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_doublecheck,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_difficult_decision,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_fear_travel,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_trouble_breathe,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_hot_cold,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_avoid,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_mind_blank,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_body_numb,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_punish_sins,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_hopeless_future,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_trouble_concentrate,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_weak_body,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_tense,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_death_thoughts,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_urge_harm,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_urge_break,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_self_conscious,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_uneasy_crowds,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_never_close,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_terror_spells,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_argue,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_nervous_alone,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_no_credit,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_restless,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_worthless,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_advantage,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_guilt,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :bsi_mind_wrong,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["0", "1", "2", "3", "4", "-4"] }
    property   :respondent_fname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :respondent_lname,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => true, :length => 0..30 }
    property   :respondent_rel,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "6", "-5", "-4"] }
    property   :respondent_rel_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :age,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :respondent_sex,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-1", "-2", "-4"] }
    property   :bsi_date_comp,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }

    mdes_order :psu_id, :bsi_saq_id, :recruit_type, :du_id, :p_id, :r_p_id, :event_id, :event_type, :event_repeat_key, :instrument_id, :instrument_type, :instrument_version, :instrument_repeat_key, :bsi_nervous, :bsi_faintness, :bsi_control_thoughts, :bsi_blame_others, :bsi_memory_trouble, :bsi_annoy_easy, :bsi_chest_pain, :bsi_afraid_streets, :bsi_suicide_thoughts, :bsi_no_trust, :bsi_no_appetite, :bsi_scared, :bsi_temper_outburst, :bsi_lonely_people, :bsi_blocked, :bsi_lonely, :bsi_blue, :bsi_no_interest, :bsi_fearful, :bsi_easily_hurt, :bsi_people_unfriendly, :bsi_inferior, :bsi_nausea, :bsi_watched, :bsi_trouble_sleep, :bsi_doublecheck, :bsi_difficult_decision, :bsi_fear_travel, :bsi_trouble_breathe, :bsi_hot_cold, :bsi_avoid, :bsi_mind_blank, :bsi_body_numb, :bsi_punish_sins, :bsi_hopeless_future, :bsi_trouble_concentrate, :bsi_weak_body, :bsi_tense, :bsi_death_thoughts, :bsi_urge_harm, :bsi_urge_break, :bsi_self_conscious, :bsi_uneasy_crowds, :bsi_never_close, :bsi_terror_spells, :bsi_argue, :bsi_nervous_alone, :bsi_no_credit, :bsi_restless, :bsi_worthless, :bsi_advantage, :bsi_guilt, :bsi_mind_wrong, :respondent_fname, :respondent_lname, :respondent_rel, :respondent_rel_oth, :age, :respondent_sex, :bsi_date_comp

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointThree
