require 'ncs_navigator/warehouse'

require 'forwardable'
require 'treetop'

module NcsNavigator::Warehouse::Transformers
  ##
  # A transformer that executes raw SQL (most likely INSERTs or UPDATEs) on the
  # warehouse working database during ETL. It captures and reports affected
  # record counts and errors.
  class SqlTransformer
    class << self
      ##
      # Splits a string into separate SQL statements on semicolons. It attempts
      # to avoid splitting on semicolons that are in string literals, though it
      # only currently supports standard SQL string literals completely. It will
      # not properly handle PostgreSQL `E''` string literals that contain
      # backslash-escaped single quotes.
      def extract_statements(s)
        Treetop.load File.expand_path('../sql/sql_statements.treetop', __FILE__)

        parser = Sql::SqlStatementsParser.new
        if result = parser.parse(s)
          result.statements
        else
          fail "Parse failed: #{parser.failure_reason}"
        end
      end
    end

    extend Forwardable
    include NcsNavigator::Warehouse::StringifyTrace

    def_delegators :@configuration, :shell, :log
    attr_reader :statements, :name

    ##
    # Creates a new SqlTransformer. You must provide at exactly one of the
    # `:statements`, `:file`, or `:script` options. If you provide more than one
    # the behavior of this transformer is undefined.
    #
    # @param [Configuration] configuration
    # @param [Hash<Symbol, Object>] options
    #
    # @option options :statements [Array<String>] a list of SQL statements
    #   already separated into strings. These strings will be sent as-is to the
    #   database (no further processing).
    # @option options :file [String] the name of a file from which to read
    #   semicolon-separated SQL statements. The file will be separated into
    #   statements using {.extract_statements}.
    # @option options :script [String] a string containing semicolon-separated
    #   SQL statements. The string will be separated into statements using
    #   {.extract_statements}.
    # @option options :name [String] the name to use when describing this
    #   transformer. A default will be generated if not provided.
    # @option options :adapter [a datamapper adapter object] the adapter
    #   against which to `execute` the statements. The default is nearly always
    #   fine; this option is provided for testing.
    def initialize(configuration, options={})
      @configuration = configuration
      @statements = select_statements(options)
      @name = options.delete(:name) ||
        "SQL Transformer with #{statements.size} statement#{statements.size == 1 ? '' : 's'}"
      @adapter = options.delete(:adapter)
    end

    ##
    # Executes the configured SQL statments, one at time, stopping at the first
    # error.
    #
    # @return [void]
    # @param [TransformStatus] transform_status
    def transform(transform_status)
      stmt_ct = statements.size
      statements.each_with_index do |stmt, i|
        log.info("Executing SQL statement in SQL transformer: \n#{stmt}")
        shell.clear_line_and_say("[#{name}] Executing statement #{i + 1}/#{stmt_ct}...")
        begin
          result = adapter.execute(stmt)
          transform_status.record_count += result.affected_rows
          log.debug("Previous statement affected #{result.affected_rows} row#{result.affected_rows == 1 ? '' : 's'}.")
        rescue Exception => e
          transform_status.transform_errors << NcsNavigator::Warehouse::TransformError.
            for_exception(e, "Exception while executing SQL statement \"#{stmt}\" (#{i + 1} of #{stmt_ct}).")
          shell.clear_line_and_say("[#{name}] Failed on #{i + 1}/#{stmt_ct}.\n")
          log.error("Previous statement failed with exception.\n#{e.class}: #{e}\n#{stringify_trace(e.backtrace)}")
          return
        end
      end
      shell.clear_line_and_say("[#{name}] Executed #{stmt_ct} SQL statement#{stmt_ct == 1 ? '' : 's'}.\n")
    end

    private

    def adapter
      # Don't memoize if an adapter was not provided as an option.
      @adapter || ::DataMapper.repository(:mdes_warehouse_working).adapter
    end

    def select_statements(options)
      if options[:statements]
        options[:statements]
      elsif options[:script]
        self.class.extract_statements(options[:script])
      elsif options[:file]
        self.class.extract_statements(File.read(options[:file]))
      else
        fail "One of :file, :script, or :statements must be specified."
      end
    end
  end
end
