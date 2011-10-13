require 'ncs_navigator/warehouse'
require 'ncs_navigator/configuration'
require 'ncs_navigator/mdes'

module NcsNavigator::Warehouse
  class Configuration
    Error = Class.new(::StandardError)

    ####
    #### Transformers
    ####

    def transformers
      @transformers ||= []
    end

    ##
    # Adds a transformer to the list for this warehouse instance.
    #
    # @return [void]
    # @param [#transform] the transformer object.
    def add_transformer(candidate)
      if candidate.respond_to?(:transform)
        self.transformers << candidate
      else
        if candidate.respond_to?(:new)
          raise Error, "#{candidate.inspect} does not have a transform method. Perhaps you meant #{candidate.inspect}.new?"
        else
          raise Error, "#{candidate.inspect} does not have a transform method."
        end
      end
    end

    ####
    #### MDES version
    ####

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
        raise Error, "No warehouse models exist for MDES version #{version_number}: #{e}"
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

    ####
    #### Suite configuration
    ####

    ##
    # @return [NcsNavigator::Configuration] a suite configuration
    #   object. Defaults to the global default instance
    #   (`NcsNavigator.configuration`) which is loaded from
    #   `/etc/nubic/ncs/navigator.ini`.
    def navigator
      @navigator ||= NcsNavigator.configuration
    end
    attr_writer :navigator

    ##
    # @param [String] ini_file an INI file that is compatible with
    #   `NcsNavigator::Configuration`.
    # @return [void]
    def navigator_ini=(ini_file)
      @navigator = NcsNavigator::Configuration.new(ini_file)
    end

    ####
    #### Terminal output
    ####

    ##
    # @return [:normal, :quiet] the desired terminal output
    #   level. This does not affect logging. Default is `:normal`.
    def output_level
      @output_level ||= :normal
    end

    ##
    # Set the desired terminal output level.
    #
    # @return [void]
    # @param [:normal, :quiet] level
    def output_level=(level)
      level = level.try(:to_sym)
      if [:normal, :quiet].include?(level)
        @output_level = level
      else
        fail Error, "#{level.inspect} is not a valid value for output_level."
      end
    end

    ##
    # The IO to use for terminal monitoring output. Defaults to
    # standard error. Use {#shell} to actually write to it.
    def shell_io
      @shell_io ||= $stderr
    end
    attr_writer :shell_io

    ##
    # The terminal output shell for command line components to use.
    # It will be an {UpdatingShell} or something which behaves like
    # one.
    def shell
      @shell ||=
        case output_level
        when :normal
          UpdatingShell.new(shell_io)
        when :quiet
          UpdatingShell::Quiet.new
        else
          fail "Unexpected output_level #{output_level.inspect}"
        end
    end
  end
end

