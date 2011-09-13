require 'bcdatabase'
require 'ncs_navigator/mdes'

module NcsNavigator
  module Warehouse
    ##
    # The default version of MDES for this version of the warehouse.
    DEFAULT_MDES_VERSION = '2.0'

    autoload :CLI,                 'ncs_navigator/warehouse/cli'
    autoload :DataMapper,          'ncs_navigator/warehouse/data_mapper'
    autoload :DatabaseInitializer, 'ncs_navigator/warehouse/database_initializer'
    autoload :Models,              'ncs_navigator/warehouse/models'
    autoload :TableModeler,        'ncs_navigator/warehouse/table_modeler'
    autoload :Transformers,        'ncs_navigator/warehouse/transformers'

    class << self
      ##
      # The name of the environment in which this warehouse is
      # running; ex: "development" (The default), "staging", or
      # "production". This value can be set from the environment
      # variable `NCS_NAVIGATOR_ENV`.
      #
      # @return [String]
      def env
        @env ||= ENV['NCS_NAVIGATOR_ENV'] || 'development'
      end

      ##
      # Change the warehouse's runtime environment. Using the
      # environment variable `NCS_NAVIGATOR_ENV` is preferable because
      # it will ensure that the environment is set to the desired
      # value from the beginning of the process. This method is mainly
      # for use in tests.
      #
      # @param [String] name
      # @return [String]
      def env=(name)
        @env = name
      end

      ##
      # @return [Bcdatabase::DatabaseConfigurations] the set of
      #   bcdatabase configurations to use throughout the warehouse.
      def bcdatabase
        @bcdatabase ||= Bcdatabase.load(:transforms => [:datamapper])
      end

      ##
      # Specify a set of bcdatabase configurations to use. (Mostly
      # intended for testing.)
      #
      # @param [Bcdatabase::DatabaseConfigurations] bcdb
      def bcdatabase=(bcdb)
        @bcdatabase = bcdb
      end

      ##
      # The bcdatabase group the warehouse will use to find its own
      # databases and which is used by default in {database
      # transformers Transformers::Database}.
      #
      # @return [Symbol]
      def default_bcdatabase_group
        case env
        when 'development'
          :local_postgresql
        when 'ci'
          :public_ci_postgresql9
        when 'staging'
          :ncsdb_staging
        when 'production'
          :ncsdb_prod
        else
          raise "Unknown environment #{env}. Please set the bcdatabase group yourself."
        end
      end

      ##
      # Selects and loads a set of models based on the given warehouse
      # version. Returns the module that namespaces the modules. Also
      # initializes {.mdes}.
      def use_mdes_version(version_number)
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

      ##
      # @return [NcsNavigator::Mdes::Specification] the specification
      #   (provided by `ncs_mdes`) for the active MDES version.
      def mdes
        @mdes or fail "Call use_mdes_version first to select an MDES version"
      end
      attr_writer :mdes

      ##
      # @return [Module] the module namespacing the models for the
      #   active MDES version.
      def models_module
        @models_module or fail "Call use_mdes_version first to load the models"
      end
      attr_writer :models_module
    end
  end
end
