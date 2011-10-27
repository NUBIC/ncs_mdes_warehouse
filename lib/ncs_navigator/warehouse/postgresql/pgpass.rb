require 'ncs_navigator/warehouse'

require 'pathname'
require 'forwardable'

module NcsNavigator::Warehouse::PostgreSQL
  class Pgpass
    extend Forwardable

    ##
    # Converts a database configuration hash into the elements of the
    # corresponding .pgpass line.
    #
    # @param [Hash<String, String>] the configuration
    # @return [Array<String>]
    def self.line(entry)
      [
        entry['host'] || 'localhost',
        (entry['port'] || 5432).to_s,
        '*',
        entry['username'] || fail("No username in configuration #{entry.inspect}"),
        entry['password'] || fail("No password in configuration #{entry.inspect}")
      ]
    end

    def_delegator self, :line

    attr_reader :file

    def initialize
      @file = Pathname.new(ENV['HOME']) + '.pgpass'
    end

    ##
    # Updates the `.pgpass` file so that it includes the current
    # password for the given configuration. This may involve adding an
    # entry, replacing an entry, or even creating the file entirely.
    #
    # @param [Hash] entry a database configuration hash
    # @return [void]
    def update(entry)
      ensure_file_exists_and_is_writable

      new_line = self.line(entry)
      contents = file.readlines.collect { |l| l.chomp.split(':') }
      match = contents.detect { |line| line[0..3] == new_line[0..3] }

      if match
        match[4] = entry['password']
      else
        contents << new_line
      end

      file.open('w') do |f|
        contents.each do |l|
          f.puts l.join(':')
        end
      end
      file.chmod(0600)
    end

    private

    def ensure_file_exists_and_is_writable
      if file.exist?
        if file.writable?
          # do nothing
        else
          fail "Cannot update #{file}"
        end
      elsif file.parent.writable?
        # touch
        file.open('w') { |f| }
      else
        fail "Cannot create #{file}"
      end
    end
  end
end
