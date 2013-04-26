require 'ncs_navigator/warehouse'

class NcsNavigator::Warehouse::Configuration
  ##
  # @private Implementation detail.
  class FileEvaluator
    attr_reader :configuration
    alias :c :configuration

    def initialize(filename)
      @filename = Pathname.new(filename)
      unless @filename.absolute?
        @filename = @filename.realpath
      end
      @base_configuration = NcsNavigator::Warehouse::Configuration.new
      @configuration = ErrorAccumulator.new(@base_configuration, @filename)
    end

    def eval
      instance_eval(File.read(@filename), @filename)
      configuration.finish
      @evaled = true
    end

    def result
      eval unless @evaled
      @base_configuration
    end

    def self.const_missing(const)
      [NcsNavigator::Warehouse::Transformers, NcsNavigator::Warehouse::Filters].each do |ns|
        if ns.const_defined?(const)
          return ns.const_get(const)
        end
      end
      super
    end
  end

  ##
  # @private Implementation detail.
  class ErrorAccumulator
    attr_reader :base_configuration

    def initialize(configuration, filename)
      @filename = filename
      @base_configuration = configuration
      @base_configuration.configuration_file = @filename
      @errors = []
    end

    def method_missing(name, *args)
      begin
        base_configuration.send(name, *args)
      rescue Error => e
        @errors << [e, find_calling_line_number]
      end
    end

    def find_calling_line_number
      file_offset = RUBY_VERSION < '1.9' ? 1 : 2
      caller[file_offset].split(':')[1]
    end
    private :find_calling_line_number

    def finish
      unless @errors.empty?
        messages = @errors.collect { |e, l| " line #{l}: #{e}" }
        raise Error, "Problem#{'s' if messages.size > 1} in #{@filename}:\n#{messages.join("\n")}"
      end
    end
  end
end
