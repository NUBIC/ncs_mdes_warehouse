require 'ncs_navigator/warehouse'

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
  #       # Include the models for the version of the MDES this
  #       # transformer is compatible with
  #       include NcsNavigator::Warehouse::Models::TwoPointZero
  #
  #       bcdatabase :name => 'ncs_staff_portal'
  #
  #       produce_records(:staff) do |row|
  #         Staff.new(
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
  #       ) do |row|
  #         StaffLanguages.new(
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
          "Producing records from %-#{producer_name_length}s (%-22s)" % [rp.name, 'loading'])
        log.debug("Executing query for producer #{rp.name}:\n#{rp.query}")
        repository.adapter.select(rp.query).each do |row|
          row_count += 1
          [*rp.row_processor.call(row)].each do |result|
            yield result
            result_count += 1
            shell.back_up_and_say(24, "(%-6d in / %-6d out)" % [row_count, result_count])
          end
          shell.back_up_and_say(24, "(%-6d in / %-6d out)" % [row_count, result_count])
        end
        log.debug("Producer #{rp.name} complete")
      end
      shell.say_line "\nComplete"

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
      # @param [Symbol] name the name of this producer; if you don't
      #   specify a `:query`, the default is to return every row from
      #   the application table with this name.
      # @param [Hash] options
      # @param [Proc] logic an expression which receives one row from the
      #   data source and returns 0 or more warehouse records. The
      #   return value may be nil (for 0), a single instance, or an Array.
      # @option options :query [String] the query to execute for this
      #   producer. If not specified, the query is `"SELECT * FROM #{name}"`.
      # @return [void]
      def produce_records(name, options={}, &logic)
        record_producers << RecordProducer.new(name, options[:query], logic)
      end
    end

    ##
    # @private
    class RecordProducer < Struct.new(:name, :query, :row_processor)
      def query
        super || "SELECT * FROM #{name}"
      end
    end

    ##
    # Methods to assist with using classes that mix in {Database}.
    module Factory
      ##
      # @return [#transform] a full transformer that uses this
      #   enumerable.
      # @see EnumTransformer
      def create_transformer(configuration, options={})
        EnumTransformer.new(new(configuration, options))
      end
    end
  end
end
