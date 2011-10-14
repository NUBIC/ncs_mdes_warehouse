require 'ncs_navigator/warehouse'

require 'thor'

module NcsNavigator::Warehouse
  class CLI < Thor
    class_option 'mdes-version', :type => :string, :default => DEFAULT_MDES_VERSION,
      :desc => 'The MDES version for the warehouse in use', :banner => 'X.Y'
    class_option :quiet, :type => :boolean, :default => false, :aliases => %w(-q),
      :desc => 'Suppress the status messages printed to standard error'

    no_tasks {
      def configuration
        @configuration ||= Configuration.new.tap do |c|
          c.mdes_version = options['mdes-version']
          c.output_level = :quiet if options['quiet']
        end
      end

      def use_database(which=:reporting)
        NcsNavigator::Warehouse::DatabaseInitializer.new(configuration).set_up_repository(which)
      end
    }

    desc 'create-schema', '(Re)builds the schema in the working database'
    def create_schema
      db = DatabaseInitializer.new(configuration)
      db.set_up_repository(:working)
      db.replace_schema
    end

    desc 'emit-xml [FILENAME]', 'Generates the VDR submission XML'
    long_desc <<-DESC
Generates and zips the vanguard data repository submission XML from
the contents of the current reporting database. The default name for
the XML file is the county name for the PSU plus the date; e.g.,
cook-20110728.xml.
DESC
    def emit_xml(filename=nil)
      use_database

      XmlEmitter.new(configuration, filename).emit_xml
    end
  end
end

