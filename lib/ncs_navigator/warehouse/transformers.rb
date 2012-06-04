require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # Data transformers and related code. A transformer in MDES
  # Warehouse is an object that has a `#transform` method that uses
  # some configured or implied input and converts it into records in
  # the warehouse.
  #
  # {Transformers::EnumTransformer} is a transformer that takes an
  # `Enumerable` of MDES Warehouse model instances, validates and
  # saves them. It's a good general base for your own transformers.
  module Transformers
    autoload :Database,              'ncs_navigator/warehouse/transformers/database'
    autoload :EnumTransformer,       'ncs_navigator/warehouse/transformers/enum_transformer'
    autoload :ForeignKeyIndex,       'ncs_navigator/warehouse/transformers/foreign_key_index'
    autoload :SamplingUnits,         'ncs_navigator/warehouse/transformers/sampling_units'
    autoload :SubprocessTransformer, 'ncs_navigator/warehouse/transformers/subprocess_transformer'
    autoload :VdrXml,                'ncs_navigator/warehouse/transformers/vdr_xml'
  end
end
