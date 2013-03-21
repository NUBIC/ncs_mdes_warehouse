require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Models::ThreePointTwo
  class StudyCenter
    include DataMapper::Resource
    include NcsNavigator::Warehouse::Models::MdesModel

    storage_names[:default] = 'study_center'
    storage_names[:mdes_warehouse_reporting] =
      storage_names[:mdes_warehouse_working] = storage_names[:default]

    property   :sc_id,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :key => true, :required => true, :length => 2..8, :set => ["20000013", "20000015", "20000019", "20000022", "20000024", "20000026", "20000029", "20000031", "20000033", "20000036", "20000038", "20000041", "20000043", "20000047", "20000049", "20000051", "20000053", "20000056", "20000059", "20000061", "20000064", "20000066", "20000068", "20000071", "20000073", "20000074", "20000075", "20000076", "20000077", "20000078", "20000080", "20000081", "20000082", "20000120", "20000121", "20000122", "-4", "20000000"] }
    property   :sc_name,
               NcsNavigator::Warehouse::DataMapper::NcsString,
               { :length => 0..100 }
    property   :comments,
               NcsNavigator::Warehouse::DataMapper::NcsText,
               { :pii => :possible, :length => 0..8000 }

    mdes_order :sc_id, :sc_name, :comments

  end # class
end # module NcsNavigator::Warehouse::Models::ThreePointTwo
