require 'ncs_navigator/warehouse'

require 'active_support/core_ext/string'

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

    def self.included(cls)
      cls.extend DSL
    end

    def initialize(options={})
      @repository_name = options.delete(:repository) || options.delete(:repository_name)
      @bcdatabase = (self.class.bcdatabase.merge(options.delete(:bcdatabase) || {}))
    end

    def repository_name
      @repository_name ||= self.class.repository_name
    end

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
    # @param [Array<Symbol>] producers if listed, only execute the
    #   named producers. Intended for isolated testing of each defined
    #   producer.
    def each(*producers)
      rps =
        if producers.empty?
          self.class.record_producers
        else
          producers.collect do |p_name|
            self.class.record_producers.detect { |rp| rp.name == p_name } ||
             fail("No producer named #{p_name.inspect} in #{self.class}")
          end
        end
      rps.each do |rp|
        repository.adapter.select(rp.query).each do |row|
          [*rp.row_processor.call(row)].each do |result|
            yield result
          end
        end
      end
    end

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
          @bcdatabase ||= { :group => NcsNavigator::Warehouse.default_bcdatabase_group }
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
  end
end
