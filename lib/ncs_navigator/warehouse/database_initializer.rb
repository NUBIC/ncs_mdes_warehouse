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

    def_delegators :@configuration, :shell, :log

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
      log.info "Connecting DataMapper repository #{dm_name.inspect}"
      p = params(which_one)
      log.debug "  using #{p.merge('password' => 'SUPPRESSED').inspect}"
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
      drop_all(:working)

      shell.say "Loading MDES models..."
      log.info "Initializing schema for MDES #{configuration.mdes.specification_version}"
      # In DM 1.2, DataMapper.auto_migrate! only works for the
      # :default repo
      ::DataMapper::Model.descendants.each do |m|
        shell.clear_line_then_say "Adding #{m.storage_name(:mdes_warehouse_working)}..."
        m.auto_migrate!(:mdes_warehouse_working)
      end
      shell.clear_line_then_say(
        "Added #{configuration.models_module.mdes_order.size} MDES tables.\n")
    end

    def drop_all(which)
      shell.say "Dropping everything in #{which} schema"
      log.info "Dropping everything in #{which} schema"
      ::DataMapper.repository(:"mdes_warehouse_#{which}").adapter.
        execute("DROP OWNED BY #{params(which)['username']}")
      shell.clear_line_then_say "Dropped everything in #{which} schema.\n"
    end
    private :drop_all

    ##
    # Replaces the reporting database with a clone of the working
    # database. This method relies on the command line `pg_dump` and
    # `pg_restore` commands. In addition, you must also have
    # previously called {#set_up_repository} with `:both` as the
    # argument.
    #
    # @return [true,false] whether the clone succeeded.
    # @see Configuration#pg_bin_path
    def clone_working_to_reporting
      PostgreSQL::Pgpass.new.tap do |pgpass|
        pgpass.update params(:working)
        pgpass.update params(:reporting)
      end

      dump_cmd = [
        configuration.pg_bin('pg_dump'),
        pg_params(params(:working)),
        '--format=custom',
        params(:working)['database']
      ].flatten

      restore_cmd = [
        configuration.pg_bin('pg_restore'),
        pg_params(params(:reporting)),
        '--schema', 'public',
        '--dbname', params(:reporting)['database']
      ].flatten

      drop_all(:reporting)

      command = "#{escape_cmd dump_cmd} | #{escape_cmd restore_cmd}"
      shell.say 'Cloning working schema into reporting schema...'
      log.info('Cloning working schema into reporting schema')
      log.debug("Clone command: #{command.inspect}")
      unless system(command)
        shell.clear_line_then_say(
          "Clone from working to reporting failed. See above for detail.\n")
        log.error('Clone failed.')
        return false
      else
        shell.clear_line_then_say("Clone from working to reporting successful.\n")
        log.info('Clone succeeded.')
        return true
      end
    end

    def pg_params(p)
      [
        pg_param(p, 'host'),
        pg_param(p, 'port'),
        pg_param(p, 'username'),
        '-w'
      ].compact.flatten
    end
    private :pg_params

    def pg_param(p, param_name)
      ["--#{param_name}", p[param_name]] if p[param_name]
    end
    private :pg_param

    def escape_cmd(parts)
      parts.collect { |p| "'#{p}'" }.join(' ')
    end
    private :escape_cmd
  end
end

