require 'ncs_navigator/warehouse'

require 'thor'

module NcsNavigator::Warehouse
  class CLI < Thor
    class_option 'mdes-version', :type => :string,
      :desc => 'Override the MDES version for the environment', :banner => 'X.Y'
    class_option :quiet, :type => :boolean, :aliases => %w(-q),
      :desc => 'Suppress the status messages printed to standard error'
    class_option 'config', :type => :string, :aliases => %w(-c),
      :desc => "Supply an alternate configuration file instead of the default #{Configuration.environment_file}"

    no_tasks {
      def configuration
        @configuration ||=
          begin
            base = options['config'] ?
              Configuration.from_file(options['config']) :
              Configuration.for_environment
            base.tap do |c|
              c.mdes_version = options['mdes-version'] if options['mdes-version']
              if options.has_key?('quiet')
                c.output_level = options['quiet'] ? :quiet : :normal
              end
              c.set_up_logs
            end
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

    desc 'clone-working', 'Copies the contents of the working database to the reporting database'
    def clone_working
      db = DatabaseInitializer.new(configuration)
      db.clone_working_to_reporting
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

    desc 'etl', 'Performs the full extract-transform-load process for this configuration'
    long_desc <<-DESC
Clears the working schema and repopulates it with the results of running
the all the configured transforms. If the transforms are successful, the
reporting schema is wiped and replaced with the results.
DESC
    method_option 'force', :type => 'boolean',
      :desc => 'Copy the working schema to production even if there are errors'
    def etl
      db = DatabaseInitializer.new(configuration)
      db.set_up_repository(:both)
      db.replace_schema

      success = TransformLoad.new(configuration).run
      if success || options['force']
        db.clone_working_to_reporting
      end
    end
  end
end

