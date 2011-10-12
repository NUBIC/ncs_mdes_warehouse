require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  class Configuration
    ##
    # Selects and loads a set of models based on the given warehouse
    # version. Also initializes {#mdes} and  {#models_module}.
    #
    # @return [void]
    def mdes_version=(version_number)
      module_name = TableModeler.version_module_name(version_number)
      module_require = "ncs_navigator/warehouse/models/#{module_name.underscore}"

      begin
        require module_require
      rescue LoadError => e
        raise LoadError, "No warehouse models exist for MDES version #{version_number}: #{e}"
      end

      self.mdes = NcsNavigator::Mdes(version_number)

      @models_module = NcsNavigator::Warehouse::Models.const_get module_name
    end
    attr_reader :mdes_version

    ##
    # @return [NcsNavigator::Mdes::Specification] the specification
    #   (provided by `ncs_mdes`) for the active MDES version.
    def mdes
      @mdes or fail 'Set an MDES version first'
    end
    attr_writer :mdes

    ##
    # @return [Module] the module namespacing the models for the
    #   active MDES version.
    def models_module
      @models_module or fail 'Set an MDES version first to load the models'
    end
    attr_writer :models_module
  end
end

