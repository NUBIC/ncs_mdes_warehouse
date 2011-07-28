require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Models
  ##
  # Extensions for the modules that form a namespace for a particular
  # MDES version's models. The methods here are available at the
  # module level of the namespace module.
  module MdesModelCollection
    ##
    # Sets or retrieves the required table order.
    #
    # @overload mdes_order(*model_classes)
    #   Sets the output order.
    #   @param [Array<Class>] model_classes the order
    # @overload mdes_order
    #   Retrieves the output order.
    #
    # @return [Array<Class>]
    def mdes_order(*input)
      if input.empty?
        @mdes_order
      else
        @mdes_order = input
      end
    end
  end
end
