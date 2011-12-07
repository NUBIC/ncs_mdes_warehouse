require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # A shell wrapper that allows for (and assists with) terminal
  # programs that update their output using `\r` and `\b`.
  class UpdatingShell
    def initialize(io)
      @io = io
    end

    def say(*s)
      s.each { |e| @io.write(e) }
    end

    def back_up_and_say(backup_count, s)
      say "\b" * backup_count
      say "%#{backup_count}s" % s
    end

    def clear_line_then_say(s)
      say clear_line_chars
      say s
    end
    alias :clear_line_and_say :clear_line_then_say

    def say_line(s)
      say s, "\n"
    end

    protected

    def clear_line_chars
      @clear_line_chars ||=
        begin
          cols = `tput cols`.to_i
          "\r#{' ' * cols}\r"
        end
    end

    ##
    # A version of {UpdatingShell} that doesn't actually emit anything.
    class Quiet < UpdatingShell
      def initialize
        super nil
      end

      def say(*s)
      end

      protected

      def clear_line_chars
        ""
      end
    end
  end
end
