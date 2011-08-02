require 'bcdatabase'

module NcsNavigator
  module Warehouse
    autoload :DataMapper,   'ncs_navigator/warehouse/data_mapper'
    autoload :Models,       'ncs_navigator/warehouse/models'
    autoload :TableModeler, 'ncs_navigator/warehouse/table_modeler'
    autoload :Transformers, 'ncs_navigator/warehouse/transformers'

    class << self
      ##
      # @return [Bcdatabase::DatabaseConfigurations] the set of
      #   bcdatabase configurations to use throughout the warehouse.
      def bcdatabase
        @bcdatabase ||= Bcdatabase.load
      end

      ##
      # Specify a set of bcdatabase configurations to use. (Mostly
      # intended for testing.)
      #
      # @param [Bcdatabase::Configurations] bcdb
      def bcdatabase=(bcdb)
        @bcdatabase = bcdb
      end
    end
  end
end
