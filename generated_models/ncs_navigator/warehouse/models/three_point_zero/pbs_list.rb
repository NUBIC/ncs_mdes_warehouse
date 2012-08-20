require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointZero
  class PbsList
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'pbs_list'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :psu_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..8, :set => ["20000054", "20000032", "20000032", "20000032", "20000032", "20000016", "20000039", "20000200", "20000028", "20000063", "20000067", "20000201", "20000202", "20000203", "20000090", "20000083", "20000204", "20000205", "20000042", "20000037", "20000206", "20000040", "20000207", "20000208", "20000209", "20000091", "20000210", "20000069", "20000211", "20000094", "20000212", "20000213", "20000102", "20000214", "20000215", "20000044", "20000216", "20000216", "20000216", "20000030", "20000217", "20000218", "20000218", "20000218", "20000219", "20000220", "20000221", "20000092", "20000222", "20000223", "20000224", "20000225", "20000225", "20000088", "20000087", "20000226", "20000103", "20000227", "20000228", "20000229", "20000230", "20000231", "20000232", "20000025", "20000233", "20000233", "20000233", "20000048", "20000234", "20000235", "20000050", "20000236", "20000035", "20000237", "20000238", "20000239", "20000240", "20000052", "20000241", "20000243", "20000244", "20000245", "20000246", "20000247", "20000248", "20000113", "20000249", "20000250", "20000251", "20000086", "20000252", "20000253", "20000254", "20000255", "20000256", "20000018", "20000058", "20000014", "20000257", "20000258", "20000259", "20000259", "20000098", "20000060", "20000260", "20000260", "20000260", "20000260", "20000261", "20000262", "20000263", "20000097", "20000264", "20000264", "20000265", "20000062", "20000117", "20000266", "20000267", "20000268", "20000269", "20000270", "20000271", "20000272", "20000273", "-4", "20000000"] }
    property   :pbs_list_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 1..36 }
    belongs_to :provider,
               'NcsNavigator::Warehouse::Models::ThreePointZero::Provider',
               :child_key => [ :provider_id ], :required => false
    property   :practice_num,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..3 }
    property   :in_out_frame,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..2, :set => ["1 ", "2 ", "-4"] }
    property   :in_sample,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..2, :set => ["1 ", "2 ", "-6", "-4"] }
    property   :substitute_provider_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..36 }
    property   :in_out_psu,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..2, :set => ["1 ", "2 ", "-4"] }
    property   :mos,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :cert_flag,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..2, :set => ["1 ", "2 ", "-6", "-4"] }
    property   :stratum,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..36 }
    property   :sort_var1,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :sort_var2,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :sort_var3,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :frame_order,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^([-+]?[\d]{1,9})?$/ }
    property   :selection_probability_location,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }
    property   :sampling_interval_woman,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }
    property   :selection_probability_woman,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }
    property   :selection_probability_overall,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :format => /^(([-+]?\d{1,12})|([-+]?\d{0,12}\.\d{1,6})|(\d{0,12}\.\d{1,6})|([-+]?\d{1,12}\.\d{0,6}))?$/ }
    property   :frame_completion_req,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 1..2, :set => ["1", "2", "-7", "-4"] }
    property   :pr_recruitment_status,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :required => true, :length => 2..2, :set => ["1 ", "2 ", "3 ", "4 ", "5 ", "-7", "-4"] }
    property   :pr_recruitment_start_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :pr_cooperation_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }
    property   :pr_recruitment_end_date,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..10, :format => /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])?$/ }

    mdes_order :psu_id, :pbs_list_id, :provider_id, :practice_num, :in_out_frame, :in_sample, :substitute_provider_id, :in_out_psu, :mos, :cert_flag, :stratum, :sort_var1, :sort_var2, :sort_var3, :frame_order, :selection_probability_location, :sampling_interval_woman, :selection_probability_woman, :selection_probability_overall, :frame_completion_req, :pr_recruitment_status, :pr_recruitment_start_date, :pr_cooperation_date, :pr_recruitment_end_date

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointZero