require 'ncs_navigator/warehouse'

require 'bcdatabase'
require 'benchmark'
require 'forwardable'
require 'tempfile'

require 'ncs_navigator/warehouse/data_mapper'
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
    #   be the working repo unless only the reporting repo is
    #   configured in.
    # @return [void]
    def set_up_repository(mode=:reporting, prefix="mdes_warehouse")
      fail "Invalid mode #{mode.inspect}" unless [:reporting, :working, :both].include?(mode)
      modes = case mode
              when :both then [:working, :reporting]
              else [mode]
              end
      connect_one(modes.first, :default)
      modes.each { |m| connect_one(m, [prefix, m].join('_').to_sym) }
    end

    def connect_one(which_one, dm_name)
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
      shell.clear_line_then_say("Creating schema in working database...")
      ::DataMapper.auto_migrate!

      shell.clear_line_then_say(
        "Added #{configuration.models_module.mdes_order.size} MDES tables.\n")

      create_no_pii_views
    end

    def drop_all_null_constraints(which, options={})
      shell.clear_line_then_say "Dropping all NOT NULL constraints in #{which} schema" unless options[:quiet]
      models = ::DataMapper::Model.descendants
      adapter = ::DataMapper.repository(:"mdes_warehouse_#{which}").adapter

      models.each do |model|
        model.properties.each do |property|
          # Skip if NULLS are allowed or column is part of the primary key
          next if property.allow_blank? || model.key.include?(property)
          adapter.execute(%Q|
            ALTER TABLE #{model.storage_name}
            ALTER COLUMN #{property.name}
            DROP NOT NULL
          |)
        end
      end

      shell.clear_line_then_say "Dropped all NOT NULL constraints in #{which} schema.\n" unless options[:quiet]
    end

    # @private Exposed for use in tests
    def drop_all(which, options={})
      shell.clear_line_then_say "Dropping everything in #{which} schema" unless options[:quiet]
      log.info "Dropping everything in #{which} schema..."
      ::DataMapper.repository(:"mdes_warehouse_#{which}").adapter.
        execute("DROP OWNED BY #{params(which)['username']}")
      shell.clear_line_then_say "Dropped everything in #{which} schema.\n" unless options[:quiet]
    end

    def create_no_pii_views
      no_pii_schema = 'no_pii'
      shell.say("Creating no-PII views...")

      views = configuration.models_module.mdes_order.collect do |model|
        selects = model.properties.collect { |p|
          [p.pii ? "varchar(32) '[pii=#{p.pii}]'" : p.name, p.name].join(' AS ')
        }
        %Q(CREATE VIEW #{no_pii_schema}.#{model.mdes_table_name}
             AS SELECT #{selects.join(',')} FROM public.#{model.mdes_table_name})
      end
      ::DataMapper.repository(:mdes_warehouse_working).adapter.
        execute("CREATE SCHEMA #{no_pii_schema} #{views.join("\n")}")
      shell.clear_line_then_say("Created no-PII views.\n")

      role_name = 'mdes_warehouse_no_pii'
      role_exists = ::DataMapper.repository(:mdes_warehouse_working).adapter.
        select("SELECT rolname FROM pg_catalog.pg_roles WHERE rolname='#{role_name}'").size > 0
      if role_exists
        shell.say("- Granting SELECT on no-PII views to #{role_name}...")
        [
          "GRANT USAGE ON SCHEMA #{no_pii_schema} TO #{role_name}",
          "GRANT SELECT ON ALL TABLES IN SCHEMA #{no_pii_schema} TO #{role_name}"
        ].each do |stmt|
          ::DataMapper.repository(:mdes_warehouse_working).adapter.execute(stmt)
        end
        shell.clear_line_then_say("- Granted SELECT on no-PII views to #{role_name}.\n")
      else
        shell.say_line(
          "- Database role #{role_name} does not exist. Performing no grants for no-PII views.")
      end
    end
    private :create_no_pii_views

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

      shell.say 'Cloning working schema into reporting schema...'

      dump_file = Tempfile.new('wh_clone_dump')

      dump_cmd = escape_cmd([
        configuration.pg_bin('pg_dump'),
        pg_params(params(:working)),
        '--format=custom',
        "--file=#{dump_file.path}",
        params(:working)['database']
      ].flatten)

      shell.clear_line_then_say(
        "Cloning working to reporting... dumping working database to temporary file")
      log.debug("Dump command: #{dump_cmd}")
      unless system(dump_cmd)
        shell.say(
          "\nClone from working to reporting failed. See above for detail.\n")
        log.error('Dump failed.')
        return false
      end

      list_file = Tempfile.new('wh_clone_list')
      list_cmd = escape_cmd([
        configuration.pg_bin('pg_restore'),
        pg_params(params(:working)),
        '--list',
        "--file=#{list_file.path}",
        dump_file.path
      ].flatten)

      shell.clear_line_then_say(
        "Cloning working to reporting... extracting dump contents")
      log.debug("List command: #{list_cmd}")
      unless system(list_cmd)
        shell.say(
          "\nClone from working to reporting failed. See above for detail.\n")
        log.error('Dump failed.')
        return false
      end

      shell.clear_line_then_say(
        "Cloning working to reporting... filtering content list")
      list_file.rewind
      selection_file = Tempfile.new('wh_clone_selection')
      list_file.read.split("\n").each do |line|
        if line =~ %r{#{params(:working)['username']}$}
          selection_file.puts line
        end
      end

      restore_cmd = escape_cmd([
        configuration.pg_bin('pg_restore'),
        pg_params(params(:reporting)),
        "--use-list=#{selection_file.path}",
        '--dbname', params(:reporting)['database'],
        dump_file.path
      ].flatten)

      drop_all(:reporting, :quiet => true)

      shell.clear_line_then_say(
        "Cloning working to reporting... loading filtered dump into reporting database")
      log.debug("Restore command: #{restore_cmd.inspect}")
      if system(restore_cmd)
        shell.clear_line_then_say("Successfully cloned working to reporting.\n")
        log.info('Clone succeeded.')
        return true
      else
        shell.say(
          "\nClone from working to reporting failed. See above for detail.\n")
        log.error('Dump failed.')
        return false
      end
    ensure
      dump_file.unlink if dump_file
      list_file.unlink if list_file
      selection_file.unlink if selection_file
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
