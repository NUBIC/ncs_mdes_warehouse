require 'ncs_navigator/warehouse'

require 'bcdatabase'
require 'data_mapper'
require 'benchmark'
require 'forwardable'

require 'ncs_navigator/warehouse/data_mapper_patches'

module NcsNavigator::Warehouse
  ##
  # Performs configuration of the two DataMapper repositories used by
  # the warehouse. If you need to access the warehouse from your
  # application/script, do something like this first:
  #
  #     # Require the appropriate model version for the warehouse
  #     # you're using
  #     require 'ncs_navigator/warehouse/models/two_point_zero'
  #     DatabaseInitializer.new(Configuration.new).set_up_repository
  #
  # This sets up the `:default` DataMapper repository to point to the
  # reporting database for your current {NcsNavigator.env}.
  #
  # You can also set up connections to the working database if needed;
  # see below.
  class DatabaseInitializer
    extend Forwardable

    attr_reader :configuration

    def_delegator :@configuration, :shell

    def initialize(config)
      @configuration = config
    end

    ##
    # Configure the DataMapper repositories for the warehouse using
    # the appropriate bcdatabase configurations.
    #
    # @param mode [:reporting, :working, :both] which repositories to
    #   set up. In general, the working database should only be needed
    #   internal to the warehouse's scripts. The `:default` repo will
    #   be the reporting repo unless only the working repo is
    #   configured in.
    # @return [void]
    def set_up_repository(mode=:reporting)
      fail "Invalid mode #{mode.inspect}" unless [:reporting, :working, :both].include?(mode)
      modes = case mode
              when :both then [:reporting, :working]
              else [mode]
              end
      connect_one(modes.first, :default)
      modes.each { |m| connect_one(m) }
    end

    def connect_one(which_one, dm_name=nil)
      dm_name ||= :"mdes_warehouse_#{which_one}"
      adapter = ::DataMapper.setup(dm_name, params(which_one))
    end
    private :connect_one

    def params(which_one)
      NcsNavigator::Warehouse.bcdatabase[
        configuration.bcdatabase_group,
        configuration.bcdatabase_entries[which_one]
      ]
    end
    private :params

    ##
    # Drops and rebuilds the schema in the working database. The
    # models for the version of the database you're working with must
    # already be loaded and finalized. You must also have previously
    # called {#set_up_repository} with `:working` or `:both` as the
    # argument.
    #
    # @return [void]
    def replace_schema
      # TODO: actual logging, too
      shell.say_line(Benchmark.measure do
        shell.say_line "Drop everything"
        ::DataMapper.repository(:mdes_warehouse_working).adapter.
          execute("DROP OWNED BY #{params(:working)['username']}")
        shell.say_line "Initialize schema"
        # In DM 1.2, DataMapper.auto_migrate! only works for the
        # :default repo
        configuration.models_module.mdes_order.each do |m|
          m.auto_migrate!(:mdes_warehouse_working)
        end
      end)
    end
  end
end

