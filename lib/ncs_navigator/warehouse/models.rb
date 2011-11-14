require 'ncs_navigator/warehouse'

# ensure that this model is loaded along with the others
require 'ncs_navigator/warehouse/transform_status'

module NcsNavigator::Warehouse
  module Models
    autoload :MdesModel,           'ncs_navigator/warehouse/models/mdes_model'
    autoload :MdesModelCollection, 'ncs_navigator/warehouse/models/mdes_model_collection'

    # Generated modules
    autoload :TwoPointZero, 'ncs_navigator/warehouse/models/two_point_zero'
  end
end
