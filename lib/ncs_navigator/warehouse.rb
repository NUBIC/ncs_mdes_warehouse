require 'bcdatabase'

module NcsNavigator
  module Warehouse
    autoload :DataMapper,   'ncs_navigator/warehouse/data_mapper'
    autoload :Models,       'ncs_navigator/warehouse/models'
    autoload :TableModeler, 'ncs_navigator/warehouse/table_modeler'
    autoload :Transformers, 'ncs_navigator/warehouse/transformers'

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
      # @param [Bcdatabase::Configurations] bcdb
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
