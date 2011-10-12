require 'bcdatabase'
require 'ncs_navigator/mdes'

module NcsNavigator
  module Warehouse
    ##
    # The default version of MDES for this version of the warehouse.
    DEFAULT_MDES_VERSION = '2.0'

    autoload :CLI,                 'ncs_navigator/warehouse/cli'
    autoload :Configuration,       'ncs_navigator/warehouse/configuration'
    autoload :DataMapper,          'ncs_navigator/warehouse/data_mapper'
    autoload :DatabaseInitializer, 'ncs_navigator/warehouse/database_initializer'
    autoload :VdrXmlReader,        'ncs_navigator/warehouse/vdr_xml_reader'
    autoload :Models,              'ncs_navigator/warehouse/models'
    autoload :TableModeler,        'ncs_navigator/warehouse/table_modeler'
    autoload :Transformers,        'ncs_navigator/warehouse/transformers'
    autoload :UpdatingShell,       'ncs_navigator/warehouse/updating_shell'
    autoload :VERSION,             'ncs_navigator/warehouse/version'
    autoload :XmlEmitter,          'ncs_navigator/warehouse/xml_emitter'

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
      # @return [void]
      def bcdatabase=(bcdb)
        @bcdatabase = bcdb
      end

      ##
      # The bcdatabase group the warehouse will use to find its own
      # databases and which is used by default in
      # {Transformers::Database database transformers}.
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
    end
  end
end
