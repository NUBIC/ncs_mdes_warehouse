require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # @api private
  module StringifyTrace
    ##
    # Utility to generate a nicely formatted string from a ruby
    # exception trace.
    #
    # @param [Array<String>] backtrace
    # @return String
    def stringify_trace(backtrace)
      # an array of arrays containing [filename, line, msg]
      trace_lines = backtrace.collect { |l| l.scan(/^(.*?)\:(\d*)\:(.*)$/).first || ['', '', l] }

      lengths = trace_lines.inject([0, 0, 0]) { |lens, components|
        0.upto(2) { |i| lens[i] = [lens[i], components[i].length].max }
        lens
      }

      format = "%#{lengths[0]}s:%#{lengths[1]}s:%s"
      trace_lines.collect { |components| format % components }.join("\n")
    end
    module_function :stringify_trace
  end
end
