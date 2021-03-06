require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::TwoPointOne
  class Incident
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'incident'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :incident_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    property   :incident_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :incident_time,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..5, :format => /^([0-9][0-9]:[0-9][0-9])?$/ }
    property   :inc_report_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :inc_report_time,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..5, :format => /^([0-9][0-9]:[0-9][0-9])?$/ }
    belongs_to :inc_staff_reporter,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Staff',
               :child_key => [ :inc_staff_reporter_id ], :required => false
    belongs_to :inc_staff_supervisor,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Staff',
               :child_key => [ :inc_staff_supervisor_id ], :required => false
    belongs_to :inc_recip_is_participant_record,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Participant',
               :child_key => [ :inc_recip_is_participant ], :required => false
    belongs_to :inc_recip_is_du_record,
               'NcsNavigator::Warehouse::Models::TwoPointOne::DwellingUnit',
               :child_key => [ :inc_recip_is_du ], :required => false
    belongs_to :inc_recip_is_staff_record,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Staff',
               :child_key => [ :inc_recip_is_staff ], :required => false
    belongs_to :inc_recip_is_family_record,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Person',
               :child_key => [ :inc_recip_is_family ], :required => false
    belongs_to :inc_recip_is_acquaintance_record,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Person',
               :child_key => [ :inc_recip_is_acquaintance ], :required => false
    property   :inc_recip_is_other,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    belongs_to :inc_contact_person_record,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Person',
               :child_key => [ :inc_contact_person ], :required => false
    property   :inctype,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-5", "-4"] }
    property   :inctype_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :incloss_cmptr_model,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..16 }
    property   :incloss_cmptr_sn,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..32 }
    property   :incloss_cmptr_decal,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..32 }
    property   :incloss_rem_media,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..32 }
    property   :incloss_paper,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..32 }
    property   :incloss_oth,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :pii => :possible, :length => 0..255 }
    property   :inc_description,
               NcsNavigator::Warehouse::DataMapper::NcsText,
               { :pii => :possible, :length => 0..8000 }
    property   :inc_action,
               NcsNavigator::Warehouse::DataMapper::NcsText,
               { :pii => :possible, :length => 0..8000 }
    property   :inc_reported,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-6", "-4"] }
    belongs_to :contact,
               'NcsNavigator::Warehouse::Models::TwoPointOne::Contact',
               :child_key => [ :contact_id ], :required => false

    mdes_order :psu_id, :incident_id, :incident_date, :incident_time, :inc_report_date, :inc_report_time, :inc_staff_reporter_id, :inc_staff_supervisor_id, :inc_recip_is_participant, :inc_recip_is_du, :inc_recip_is_staff, :inc_recip_is_family, :inc_recip_is_acquaintance, :inc_recip_is_other, :inc_contact_person, :inctype, :inctype_oth, :incloss_cmptr_model, :incloss_cmptr_sn, :incloss_cmptr_decal, :incloss_rem_media, :incloss_paper, :incloss_oth, :inc_description, :inc_action, :inc_reported, :contact_id

  end # class
end # module NcsNavigator::Warehouse::Models::TwoPointOne
