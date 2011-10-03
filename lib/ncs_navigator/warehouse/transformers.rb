require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  module Transformers
    autoload :Database, 'ncs_navigator/warehouse/transformers/database'
    autoload :VdrXml,   'ncs_navigator/warehouse/transformers/vdr_xml'
  end
end
