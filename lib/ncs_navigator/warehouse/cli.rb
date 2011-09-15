require 'ncs_navigator/warehouse'

require 'thor'

module NcsNavigator::Warehouse
  class CLI < Thor
    class_option 'mdes-version', :type => :string, :default => DEFAULT_MDES_VERSION,
      :desc => 'The MDES version for the warehouse in use', :banner => 'X.Y'

    no_tasks {
      def use_mdes
        NcsNavigator::Warehouse.use_mdes_version(options[:'mdes-version'])
      end

      def use_database(which=:reporting)
        NcsNavigator::Warehouse::DatabaseInitializer.new.set_up_repository(which)
      end
    }

    desc 'create-schema', '(Re)builds the schema in the working database'
    def create_schema
      use_mdes

      db = DatabaseInitializer.new
      db.set_up_repository(:working)
      db.replace_schema
    end

    desc 'emit-xml [FILENAME]', 'Generates the VDR submission XML'
    method_option :quiet, :type => :boolean, :default => false, :aliases => %w(-q),
      :desc => 'Suppress the status messages printed to standard error'
    long_desc <<-DESC
Generates and zips the vanguard data repository submission XML from
the contents of the current reporting database. The default name for
the XML file is the county name for the PSU plus the date; e.g.,
cook-20110728.xml.
DESC
    def emit_xml(filename=nil)
      use_mdes
      use_database

      XmlEmitter.new(filename, options).emit_xml
    end
  end
end

