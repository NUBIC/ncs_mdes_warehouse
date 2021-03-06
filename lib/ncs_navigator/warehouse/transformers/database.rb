require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper'

require 'active_support/core_ext/string'
require 'forwardable'

module NcsNavigator::Warehouse::Transformers
  ##
  # A mixin that provides a DSL for defining a series of application
  # database queries and the logic for transforming their results into
  # warehouse model instances. Example:
  #
  #     class StaffPortalTransformer
  #       include NcsNavigator::Warehouse::Transformers::Database
  #
  #       bcdatabase :name => 'ncs_staff_portal'
  #
  #       produce_records(:staff) do |row, meta|
  #         staff_model = meta[:configuration].model(:staff)
  #         staff_model.new(
  #           :staff_id => 'SP' + row.username
  #           # etc.
  #         )
  #       end
  #
  #       produce_records(
  #         :staff_languages,
  #         :query => %Q(
  #           SELECT sub.*, s.username
  #           FROM staff_languages sub INNER JOIN staff s ON sub.staff_id=s.id
  #         )
  #       ) do |row, meta|
  #         sl_model = meta[:configuration].model(:staff_language)
  #         sl_model.new(
  #           :staff_language_id => 'SP' + row.id,
  #           :staff_id => 'SP' + row.username,
  #           :staff_lang => row.lang_code
  #           # etc.
  #         )
  #       end
  #     end
  #
  # This mixin creates an `Enumerable` that executes all the defined
  # productions and streams their resulting values. As such, it is
  # compatible with {EnumTransformer}.
  #
  # @see Database::DSL the DSL
  module Database
    include Enumerable
    extend Forwardable

    def_delegators :@configuration, :shell, :log

    def self.included(cls)
      cls.extend DSL
      cls.extend Factory
    end

    def initialize(configuration, options={})
      @configuration = configuration
      @repository_name = options.delete(:repository) || options.delete(:repository_name)
      @bcdatabase = { :group => configuration.bcdatabase_group }.
        merge((self.class.bcdatabase.merge(options.delete(:bcdatabase) || {})))
    end

    ##
    # @return [Symbol] the name of the repository to use / set up for
    #   this instance.
    def repository_name
      @repository_name ||= self.class.repository_name
    end

    ##
    # @return [Hash] the bcdatabase group and name to use to set up
    #   the repository for the application.
    def bcdatabase
      @bcdatabase ||= self.class.bcdatabase
    end

    ##
    # @private exposed for testing
    def connection_parameters
      @params ||=
        begin
          NcsNavigator::Warehouse.bcdatabase[bcdatabase[:group], bcdatabase[:name]]
        end
    end

    ##
    # @return [DataMapper::Repository] the repository to use for
    #   querying application data.
    def repository
      @repository ||=
        begin
          log.debug("Connecting DM repo #{repository_name.inspect} with #{connection_parameters.merge('password' => 'SUPPRESSED').inspect}")
          ::DataMapper.setup(repository_name, connection_parameters)
          ::DataMapper.repository(repository_name)
        end
    end

    ##
    # The main entry point for a class that mixes in this module. It
    # evaluates the instructions defined by the {DSL#produce_records
    # DSL} and streams the results to the provided block.
    #
    # @param [Array<Symbol>] producer_names if listed, only execute
    #   the named producers. Intended for isolated testing of each
    #   defined producer.
    #
    # @return [void]
    def each(*producer_names)
      producers = selected_producers(producer_names)
      producer_name_length = producers.collect { |rp| rp.name.to_s.size }.max
      row_count = 0
      result_count = 0

      log.info(
        "Producing records from #{self.class} (#{producers.collect { |p| p.name }.join(', ')})")

      producers.each do |rp|
        shell.clear_line_then_say(
          "Producing records from %-#{producer_name_length}s (%-24s)" % [rp.name, 'loading'])
        log.debug("Executing query for producer #{rp.name}:\n#{rp.query}")
        repository.adapter.select(rp.query).each do |row|
          meta = { :configuration => @configuration }
          args = [row]
          args << meta if rp.row_processor.arity > 1

          row_count += 1
          [*rp.row_processor.call(*args)].compact.each do |result|
            yield result
            result_count += 1
            shell.back_up_and_say(26, "(%-7d in / %-7d out)" % [row_count, result_count])
          end
          shell.back_up_and_say(26, "(%-7d in / %-7d out)" % [row_count, result_count])
        end
        shell.back_up_and_say(26, "(%-7d in / %-7d out)" % [row_count, result_count])
        log.debug("Producer #{rp.name} complete")
      end
      shell.clear_line_then_say("#{self.class} complete (%-7d in / %-7d out)\n" % [row_count, result_count])

      log.info(
        "Production from #{self.class} complete. " +
        "#{result_count} MDES record#{'s' if result_count != 1} created from " +
        "#{row_count} row#{'s' if row_count != 1}.")

      nil
    end

    def selected_producers(producer_names)
      if producer_names.empty?
        self.class.record_producers
      else
        producer_names.collect do |p_name|
          self.class.record_producers.detect { |rp| rp.name == p_name } ||
            fail("No producer named #{p_name.inspect} in #{self.class}")
        end
      end
    end
    private :selected_producers

    ##
    # The DSL available when a class mixes in the {@link Database} module.
    module DSL
      ##
      # @param [Symbol] repo_name the data mapper repository to use in
      #   / set-up for this transformer.
      # @return [void]
      def repository(repo_name)
        @repository_name = repo_name
      end

      ##
      # @return [Symbol] The name defined by a previous call to
      #   {#repository}, or the default. The default is derived from
      #   the name of the class into which {Database} is mixed.
      def repository_name
        @repository_name ||= name.demodulize.underscore.to_sym
      end

      ##
      # What to do if are encountered by {#model_row}. Default is
      # `:ignore` but may be set to `:fail` for all producers using
      # this method. The value set here may be overridden per
      # {#model_row} call.
      #
      # @return [:ignore, :fail]
      def on_unused_columns(setting=nil)
        if setting
          @on_unused_columns = setting
        else
          @on_unused_columns ||= :ignore
        end
      end

      ##
      # Indicates a set of columns which which should not be checked
      # for used-ness by {#model_row}, even if the `:unused` option is
      # set to `:fail`.
      def ignored_columns(*columns)
        if columns.empty?
          @ignored_columns ||= []
        else
          @ignored_columns = columns.collect(&:to_s)
        end
      end

      ##
      # Defines the bcdatabase specification to use when connecting to
      # the database for this enumeration.
      #
      # @return [void]
      def bcdatabase(name_and_group={})
        if name_and_group.empty?
          @bcdatabase ||= { }
        else
          @bcdatabase = (self.bcdatabase || {}).merge(name_and_group)
        end
      end

      ##
      # The record producers defined by calls to {#produce_records}.
      #
      # @return [Array]
      def record_producers
        @record_producers ||= []
      end

      ##
      # Define a translation from the results of a query into one or
      # more warehouse records.
      #
      # The optional second parameter the `logic` proc/block is a hash of
      # metadata. That metadata contains a single key:
      #
      # * :configuration. Provides the {Configuration} in use by the warehouse
      #   that is executing this transformer. Among other things, this allows
      #   {dynamic lookup of models Configuration#model} based on the in-use
      #   MDES version.
      #
      # @param [Symbol] name the name of this producer; if you don't
      #   specify a `:query`, the default is to return every row from
      #   the application table with this name.
      # @param [Hash] options
      # @param [Proc] logic an expression which receives one row from the
      #   data source and returns 0 or more warehouse records. The
      #   return value may be nil (for 0), a single instance, or an Array.
      #   If the expression accepts two arguments, the second one will be
      #   a hash of metadata related to the process.
      # @option options :query [String] the query to execute for this
      #   producer. If not specified, the query is `"SELECT * FROM #{name}"`.
      # @return [void]
      def produce_records(name, options={}, &logic)
        record_producers << RecordProducer.new(name, options[:query], logic)
      end

      ##
      # Define a translation from the results of a query into exactly
      # one warehouse record per result row. This method, while more
      # restrictive than {#produce_records}, allows for rapidly
      # mapping data which is already a close match for MDES records.
      #
      # The mapping uses a series of heuristics to map from the
      # columns in each query result row to at most one MDES variable
      # from the specified model.
      #
      #   * If the column appears as a key in the `:column_map` hash,
      #     use the associated value as the target variable name.
      #   * If there's a `:prefix` option, the column is named {X},
      #     and there's a variable named {prefix}{X}, use that
      #     variable.
      #   * If the column is named {X} and there's a variable named
      #     {X}, use that variable.
      #   * If the column is named {X}_code and there's a variable
      #     named {X}, use that variable.
      #   * If the column is named {X}_code and there's a variable
      #     named {X}_id, use that variable.
      #   * If the column is named {X}_other and there's a property
      #     named {X}_oth, use that variable.
      #
      # @param [Symbol] name the name of this producer; if you don't
      #   specify a `:query`, the default is to return every row from
      #   the application table with this name.
      # @param [Class,Symbol] model_or_reference the warehouse model to which
      #   the results of the query will be mapped. It can be expressed either
      #   as the model class itself or the unqualified name of the model. (See
      #   {Configuration#model}.)
      # @param [Hash] options
      # @option options :query [String] the query to execute for this
      #   producer. If not specified, the query is `"SELECT * FROM #{name}"`.
      #
      # @option options :prefix [String] a prefix to use when looking
      #   for matching property values. (See above.)
      # @option options :column_map [Hash<Symbol, Symbol>] explicit
      #   mapping from column name to MDES variable name. This
      #   mapping is consulted before the heuristics are applied.
      # @option options :on_unused [:ignore,:fail] what to do when
      #   there are columns in the row which are not used.
      # @option options :ignored_columns [Array<[String,Symbol]>]
      #   columns to consider "used" even if the heuristic or the
      #   column map don't match them to anything.
      #
      # @return [void]
      def produce_one_for_one(name, model_or_reference, options={})
        options[:column_map] =
          (options[:column_map] || {}).inject({}) { |h, (k, v)| h[k.to_s] = v.to_s; h }
        options[:ignored_columns] = (options[:ignored_columns] || []).collect(&:to_s)

        record_producers <<
          OneForOneProducer.new(name, options.delete(:query), model_or_reference, self, options)
      end
    end

    ##
    # The class ecapsulating one call to {DSL#produce_records}
    class RecordProducer < Struct.new(:name, :query, :row_processor)
      def query
        super || "SELECT * FROM #{name}"
      end
    end

    ##
    # The class encapsulating one call to {DSL#produce_one_for_one}
    class OneForOneProducer < RecordProducer
      attr_reader :model_or_reference, :options, :dsl_host

      def initialize(name, query, model_or_reference, dsl_host, options)
        super(name, query, self)
        @model_or_reference = model_or_reference
        @dsl_host = dsl_host
        @options = options
      end

      ##
      # Produces a single instance of {#model} using the values in the
      # row as mapped by {#column_map}.
      def convert_row(row, meta)
        col_map = column_map(row.members, meta[:configuration])
        unused = row.members.collect(&:to_s) - col_map.keys - ignored_columns

        if on_unused == :fail && !unused.empty?
          raise UnusedColumnsForModelError.new(unused)
        end
        model(meta[:configuration]).new(
          col_map.inject({}) { |pv, (col_name, var_name)|
            pv[var_name] = clean_value(row[col_name]);
            pv
          }
        )
      end
      alias :call :convert_row

      ##
      # Implemented so that this class behaves like a lambda.
      def arity; 2; end

      ##
      # @param configuration [Configuration]
      #
      # @return [Class] the model for this producer. If {#model_or_reference}
      #   is a symbolic reference, this method resolves it using the given
      #   configuration.
      def model(configuration)
        case model_or_reference
        when Class
          model_or_reference
        else
          configuration.model(model_or_reference) or
            fail("There is no table or model named #{model_or_reference.inspect} in MDES #{configuration.mdes_version}.")
        end
      end

      def clean_value(v)
        if v.respond_to?(:strip)
          v.strip
        else
          v
        end
      end
      private :clean_value

      ##
      # @param [Array<String>] column_names
      # @param [Configuration] configuration the configuration to use to resolve
      #   model references, if necessary.
      #
      # @return [Hash<String, String>] a mapping from the given
      #   column names to MDES variable names for the configured
      #   model. This mapping reflects both the configured explicit
      #   mapping and the heuristic.
      def column_map(column_names, configuration)
        available_props = model(configuration).properties.collect { |p| p.name.to_s }
        available_props -= options[:column_map].values

        column_names.inject(options[:column_map].dup) do |map, column|
          column = column.to_s
          prop =
            unless options[:column_map][column]
              [
                [//,        ''],
                [/_code$/,  ''],
                [/_code$/,  '_id'],
                [/_other$/, '_oth'],
              ].collect do |pattern, substitution|
                if column =~ pattern
                  prefixed_property_name(available_props,
                    column.sub(pattern, substitution), options[:prefix])
                end
              end.compact.first
            end
          if prop
            available_props.delete(prop)
            map[column] = prop
          end
          map
        end
      end

      def prefixed_property_name(available_props, name, prefix)
        if prefix && available_props.include?(prop = "#{prefix}#{name}")
          prop
        elsif available_props.include?(name)
          name
        end
      end
      private :prefixed_property_name

      def on_unused
        options[:on_unused] || dsl_host.on_unused_columns
      end
      private :on_unused

      def ignored_columns
        options[:ignored_columns] + dsl_host.ignored_columns
      end
      private :ignored_columns
    end

    ##
    # Methods to assist with using classes that mix in {Database}.
    module Factory
      ##
      # @return [#transform] a full transformer that uses this
      #   enumerable.
      # @see EnumTransformer
      def create_transformer(configuration, options={})
        EnumTransformer.new(configuration, new(configuration, options), options)
      end
    end

    class UnusedColumnsForModelError < StandardError
      attr_accessor :unused

      def initialize(unused)
        super(
          "#{unused.size} unused column#{'s' unless unused.size == 1} when building model. " +
          "Use :ignored_columns => %w(#{unused.join(' ')}) or :on_unused => :ignore to suppress this error.")
        @unused = unused
      end
    end
  end
end
