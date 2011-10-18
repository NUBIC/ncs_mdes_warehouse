require 'ncs_navigator/warehouse'

class NcsNavigator::Warehouse::Configuration
  ##
  # @private Implementation detail.
  class FileEvaluator
    attr_reader :configuration
    alias :c :configuration

    def initialize(filename)
      @filename = filename
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
  end

  ##
  # @private Implementation detail.
  class ErrorAccumulator
    attr_reader :base_configuration

    def initialize(configuration, filename)
      @filename = filename
      @base_configuration = configuration
      @errors = []
    end

    def method_missing(name, *args)
      begin
        base_configuration.send(name, *args)
      rescue Error => e
        @errors << [e, caller[1].split(':')[1]]
      end
    end

    def finish
      unless @errors.empty?
        messages = @errors.collect { |e, l| " line #{l}: #{e}" }
        raise Error, "Problem#{'s' if messages.size > 1} in #{@filename}:\n#{messages.join("\n")}"
      end
    end
  end
end
