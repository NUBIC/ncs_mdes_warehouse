require 'ncs_navigator/warehouse'
require 'childprocess'
require 'forwardable'
require 'json'
require 'fileutils'

module NcsNavigator::Warehouse::Transformers
  ##
  # A transformer that executes a separate executable to perform the
  # transformation. The executable should provide error information
  # on standard out. As it proceeds with the transformation, it can
  # write single line messages. Each message either be an unstructured
  # string or a single-line JSON object whose attributes are a subset
  # of the attributes on {TransformError}. If the final line can be
  # interpreted as an integer alone, it will be used as the record
  # count for the transformer. Example standard out:
  #
  #     Could not connect to frob
  #     { "record_id": "F111", "model_class": "Person", "message": "was invalid" }
  #     39
  #
  # This output will result in a {TransformStatus} with record count
  # 39 and two errors. The errors will have the messages `Could not
  # connect to frob` and `was invalid` and the latter will have the
  # identity of the specific troublesome record.
  #
  # If the subprocess is a ruby script, it may be useful to pass the
  # warehouse configuration filename as one of its arguments so it can
  # use the Warehouse API to connect to the database, etc.
  class SubprocessTransformer
    extend Forwardable

    def_delegators :configuration, :log, :shell

    ##
    # @return [Array<String>] The process parameters, including the
    #   executable name.
    attr_reader :exec_and_args

    ##
    # @return [Configuration] The warehouse configuration in use.
    attr_reader :configuration

    ##
    # @param config [Configuration]
    # @param exec_and_args [String<Array>] the arguments for the
    #   subprocess to spawn, including the executable name (which
    #   should be the first item in the array)
    # @param options [Hash]
    #
    # @option options :environment [Hash<String, String>] values to
    #   include in the subprocess's environment. The subprocess will
    #   inherit all the environment variables from the parent ETL
    #   process, so this only needs to include overrides.
    # @option options :directory [String] the directory from which to
    #   run the subprocess if different from the current working
    #   directory.
    def initialize(config, exec_and_args, options={})
      @configuration = config
      @exec_and_args = exec_and_args
      @working_directory = options[:directory] || '.'
      @environment = options[:environment] || {}
    end

    ##
    # @return [String]
    def name
      exec_and_args.join(' ')
    end

    ##
    # Spawns the child process and updates the provided
    # {TransformStatus} with the results.
    #
    # @param [TransformStatus] transform_status
    #
    # @return [void]
    def transform(transform_status)
      process = ChildProcess.build(*exec_and_args)
      process.environment.merge!(@environment)

      # inherit stderr
      process.io.inherit!

      # capture stdout
      out_r, out_w = IO.pipe
      process.io.stdout = out_w

      log.info "Spawning subprocess transformer `#{exec_and_args.join(' ')}`"
      shell.say "Spawning subprocess transformer `#{exec_and_args.join(' ')}`"

      FileUtils.cd @working_directory do
        process.start
      end

      log.info "  PID is #{process.pid}"
      shell.say_line ": #{process.pid}"
      out_w.close

      out_lines = out_r.readlines
      if !out_lines.empty? && out_lines.last.to_i.to_s == out_lines.last.strip
        transform_status.record_count = out_lines.pop.to_i
      end
      out_lines.each do |error|
        attrs =
          begin
            JSON.parse(error.strip)
          rescue JSON::ParserError => e
            { 'message' => error.strip }
          end
        transform_status.transform_errors <<
          NcsNavigator::Warehouse::TransformError.new(attrs)
      end

      unless process.exited?
        process.stop
      end

      if process.exit_code != 0
        transform_status.add_error(
          "`#{exec_and_args.join(' ')}` process exited with code #{process.exit_code}")
      end

      if transform_status.transform_errors.empty?
        shell.say_line "Subprocess completed."
      else
        shell.say_line "Subprocess completed with errors."
      end
    end
  end
end
