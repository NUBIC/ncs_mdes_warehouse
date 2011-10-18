require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Models
  ##
  # Extensions for the modules that form a namespace for a particular
  # MDES version's models. The methods here are available at the
  # module level of the namespace module.
  module MdesModelCollection
    ##
    # Sets or retrieves the version that this collection represents.
    #
    # @overload mdes_version(version_string)
    #   Sets the version.
    #   @param [String] version_string the version
    # @overload mdes_version
    #   Retrieves the version.
    #
    # @return [String]
    def mdes_version(version_string=nil)
      if version_string
        @mdes_version = version_string
      else
        @mdes_version
      end
    end

    ##
    # Sets or retrieves the specification version that this collection
    # represents.
    #
    # @overload mdes_specification_version(version_string)
    #   Sets the specification version.
    #   @param [String] version_string the version
    # @overload mdes_specification_version
    #   Retrieves the specification version.
    #
    # @return [String]
    def mdes_specification_version(version_string=nil)
      if version_string
        @mdes_specification_version = version_string
      else
        @mdes_specification_version
      end
    end

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
