require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  module Models
    autoload :MdesModel,           'ncs_navigator/warehouse/models/mdes_model'
    autoload :MdesModelCollection, 'ncs_navigator/warehouse/models/mdes_model_collection'

    # Generated modules
    autoload :TwoPointZero, 'ncs_navigator/warehouse/models/two_point_zero'
  end
end
