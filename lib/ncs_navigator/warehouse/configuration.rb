require 'ncs_navigator/warehouse'
require 'ncs_navigator/configuration'
require 'ncs_navigator/mdes'
require 'ncs_navigator/warehouse/data_mapper'

require 'active_support/core_ext/object/try'
require 'pathname'

module NcsNavigator::Warehouse
  ##
  # The configuration profile for the warehouse in a particular
  # environment. An instance of this class is derived from the
  # environment script under
  # `/etc/nubic/ncs/warehouse/{env_name}.rb`.
  #
  # @see file:sample_configuration.rb
  class Configuration
    ##
    # The error raised on a configuration problem.
    class Error < ::StandardError; end

    autoload :FileEvaluator, 'ncs_navigator/warehouse/configuration/file_evaluator'

    class << self
      ##
      # Evaluates the given file to initialize a {Configuration}
      # object. See {file:sample_configuration.ini} for an example.
      #
      # @return [Configuration] a configuration initialized from the
      #   given file.
      # @param [String] filename
      def from_file(filename)
        FileEvaluator.new(filename.to_s).result
      end

      ##
      # Loads the configuration for the named environment from
      # `/etc/nubic/ncs/warehouse/{env_name}.rb`.
      #
      # @return [Configuration] the configuration loaded from the
      #   configuration file for the named environment.
      # @param [#to_s] env_name
      def for_environment(env_name=nil)
        fn = environment_file env_name
        if File.exist?(fn)
          from_file(fn)
        else
          new
        end
      end

      def environment_file(env_name=nil)
        env_name ||= NcsNavigator::Warehouse.env
        "/etc/nubic/ncs/warehouse/#{env_name}.rb"
      end
    end

    ####
    #### Transformers
    ####

    ##
    # @return [Array<#transform>] the configured transformer objects.
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

    ##
    # The foreign key index used during an ETL run. The default value
    # is correct for virtually any case.
    #
    # @return [Object]
    def foreign_key_index
      @foreign_key_index ||= Transformers::ForeignKeyIndex.new
    end

    ##
    # Specify a different foreign key index implementation to
    # use. This will only rarely be necessary or useful. The default
    # value is correct for virtually any case.
    #
    # @return [void]
    # @param [#record_and_verify,#report_errors] index the replacement
    #   foreign key index implementation.
    def foreign_key_index=(index)
      @foreign_key_index = index
    end

    ####
    #### Hooks
    ####

    ##
    # @return [Array<#etl_succeeded,#etl_failed>] the configured
    #   post-ETL hooks.
    def post_etl_hooks
      @post_etl_hooks ||= []
    end

    ##
    # Adds a post-ETL hook to the list for this warehouse instance.
    #
    # @return [void]
    # @param [#etl_succeeded,#etl_failed] the hook
    def add_post_etl_hook(candidate)
      expected_methods = [:etl_succeeded, :etl_failed]
      implemented_methods = expected_methods.select { |m| candidate.respond_to?(m) }
      if implemented_methods.empty?
        msg = "#{candidate.inspect} does not have an #{expected_methods.join(' or ')} method."
        if candidate.respond_to?(:new)
          msg += " Perhaps you meant #{candidate}.new?"
        end
        raise Error, msg
      else
        post_etl_hooks << candidate
      end
    end

    ####
    #### MDES version
    ####

    ##
    # Selects and loads a set of models based on the given warehouse
    # version. Also initializes {#mdes} and  {#models_module}.
    #
    # @param [String] version_number the version of the MDES to use.
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

    ##
    # Returns the configured MDES version string.
    #
    # N.b.: this method triggers loading the default MDES module and
    # specification if {#mdes_version=} has not been called yet.
    #
    # @return [String] the configured MDES version.
    def mdes_version
      mdes.version
    end

    ##
    # Returns the specification for the active MDES version.
    #
    # N.b.: this method triggers loading the default MDES module and
    # specification if {#mdes_version=} has not been called yet.
    #
    # @return [NcsNavigator::Mdes::Specification] the specification
    #   (provided by `ncs_mdes`) for the active MDES version.
    def mdes
      set_default_mdes_version unless @mdes
      @mdes
    end
    attr_writer :mdes

    ##
    # Returns the module namespacing the models for the active MDES version.
    #
    # N.b.: this method triggers loading the default MDES module and
    # specification if {#mdes_version=} has not been called yet.
    #
    # @return [Module] the module namespacing the models for the
    #   active MDES version.
    def models_module
      set_default_mdes_version unless @models_module
      @models_module
    end
    attr_writer :models_module

    def set_default_mdes_version
      self.mdes_version = NcsNavigator::Warehouse::DEFAULT_MDES_VERSION
    end
    private :set_default_mdes_version

    ##
    # @param [String,Symbol] table_or_model_name either an MDES table
    #   name or the unqualified name of an MDES Warehouse model
    #
    # @return [Class,nil] the model in the current MDES version
    #   corresponding to the given model or table name, or nil if
    #   there is no such model
    def model(table_or_model_name)
      begin
        models_module.const_get(table_or_model_name)
      rescue NameError
        models_module.mdes_order.
          find { |model| model.mdes_table_name.to_s == table_or_model_name.to_s }
      end
    end

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
    # Set the suite configuration file to use in this warehouse
    # environment.
    #
    # @see {#navigator}
    # @param [String] ini_file the name of an INI file that is
    #   compatible with `NcsNavigator::Configuration`.
    # @return [void]
    def navigator_ini=(ini_file)
      @navigator = NcsNavigator::Configuration.new(ini_file)
    end

    ###
    ### E-mail
    ###

    ##
    # Configures `ActionMailer` with the options implied by the suite
    # configuration.
    #
    # @return [void]
    def set_up_action_mailer
      return if @action_mailer_set_up
      require 'action_mailer'
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = navigator.action_mailer_smtp_settings
      ActionMailer::Base.view_paths = [
        File.expand_path('../mailer_templates', __FILE__)
      ]
      @action_mailer_set_up = true
    end

    ####
    #### Bcdatabase
    ####

    ##
    # @return [Symbol] the bcdatabase group to use when locating the
    #   database configuration for this instance. It will also be used
    #   by default in {Transformers::Database} transformers.
    def bcdatabase_group
      @bcdatabase_group || default_bcdatabase_group
    end
    attr_writer :bcdatabase_group

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
    private :default_bcdatabase_group

    def env
      NcsNavigator::Warehouse.env
    end
    private :env

    ##
    # @return [Hash<Symbol, Symbol>] the bcdatabase entries to use
    #   when locating the database configurations for this
    #   instance. It must have the keys `:working` and
    #   `:reporting`.
    def bcdatabase_entries
      @bcdatabase_entries ||= default_bcdatabase_entries
    end

    def default_bcdatabase_entries
      {
        :working   => :mdes_warehouse_working,
        :reporting => :mdes_warehouse_reporting
      }
    end
    private :default_bcdatabase_entries

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
    #
    # @return [IO]
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

    ####
    #### Logging
    ####

    ##
    # The file to which the warehouse will log its actions.  Defaults
    # to `/var/log/ncs/warehouse/{env_name}.log`.
    #
    # @return [Pathname]
    def log_file
      @log_directory ||= Pathname.new("/var/log/nubic/ncs/warehouse/#{env}.log")
    end

    ##
    # Specify the filename for the warehouse's logs.
    #
    # @param [Pathname,String,nil] fn
    def log_file=(fn)
      @log_directory = coerce_to_pathname(fn)
    end

    def set_up_logs
      if log_file.writable? || log_file.parent.writable?
        @log = Logger.new(log_file).tap do |l|
          l.level = Logger::DEBUG
        end
        ::DataMapper::Logger.new(log_file, :debug, " DM: ", true)
      else
        @log = Logger.new($stdout).tap do |l|
          l.level = Logger::WARN
        end
        ::DataMapper::Logger.new($stdout, :warn, " DM: ", true)

        $stdout.puts "WARNING: Could not create or update log #{log_file}."
        $stdout.puts 'WARNING: Will log errors and warnings to standard out until this is fixed.'
      end
    end

    ##
    # @return [Logger] the primary application log
    def log
      set_up_logs unless @log
      @log
    end

    ####
    #### pg_bin
    ####

    ##
    # The path where the PostgreSQL command line utilities can be
    # found. If they are on the search path, this may be `nil` (the
    # default).
    #
    # @return [Pathname, nil]
    attr_reader :pg_bin_path

    ##
    # Specify the path where the PostgreSQL command line utilities can
    # be found.
    #
    # @param [Pathname,String,nil] fn
    # @return [void]
    def pg_bin_path=(fn)
      @pg_bin_path = coerce_to_pathname(fn)
    end

    ##
    # @return [Pathname] the executable for the given PostgreSQL
    #   utility.
    # @param [Pathname, String] command the name of the command
    def pg_bin(command)
      if pg_bin_path
        pg_bin_path + command
      else
        coerce_to_pathname command
      end
    end

    ####
    #### Meta
    ####

    ##
    # The file from which this configuration was originally read. If
    # the configuration was constructed solely in memory, this value
    # will be `nil`.
    #
    # @return [Pathname,nil]
    attr_reader :configuration_file

    ##
    # Specify the file from which this configuration was read.
    #
    # @param [Pathname,String,nil] fn
    # @return [void]
    def configuration_file=(fn)
      @configuration_file = coerce_to_pathname(fn)
    end

    private

    def coerce_to_pathname(value)
      case value
      when nil
        nil
      when Pathname
        value
      else
        Pathname.new(value)
      end
    end
  end
end

