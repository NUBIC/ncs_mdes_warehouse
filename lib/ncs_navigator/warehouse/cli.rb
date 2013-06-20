require 'ncs_navigator/warehouse'

require 'thor'

module NcsNavigator::Warehouse
  class CLI < Thor

    def initialize(args=[], options={}, config={})
      super
      @options = @options.dup
    end

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
      db.set_up_repository(:both)
      db.clone_working_to_reporting or exit(1)
    end

    desc 'emit-xml [FILENAME]', 'Generates the VDR submission XML'
    long_desc <<-DESC
Generates and zips the vanguard data repository submission XML from
the contents of the current reporting database. The default name for
the XML file is the county name for the PSU plus the date; e.g.,
cook-20110728.xml.
DESC
    method_option 'block-size', :type => :numeric, :aliases => %w(-b),
      :desc => 'The maximum number of records to have in memory at once.',
      :default => 5000
    method_option 'and-pii', :type => :boolean, :default => false,
      :desc => 'Emit one XML file without PII and one with.'
    method_option 'include-pii', :type => :boolean, :default => false,
      :desc => 'Include PII values in the emitted XML. (Usually you should prefer --and-pii.)'
    method_option 'zip', :type => :boolean, :default => true,
      :desc => 'Create a zip file alongside the XML. (Use --no-zip to disable.)'
    method_option 'directory', :type => :string, :default => nil,
      :desc => 'The target directory for automatically-named files. (Default is CWD.)'
    method_option 'tables', :type => :string,
      :desc => 'Emit XML for a subset of tables.', :banner => 'TABLE,TABLE,TABLE'
    method_option 'filters', :type => :string, :banner => 'FILTER_SET,FILTER_SET',
      :desc => 'Use these named filter sets when producing the XML. Default is set in configuration. Use --no-filters to disable default without providing an alternative.'
    def emit_xml(filename=nil)
      use_database

      options[:tables] = options[:tables].try(:split, /\s*,\s*/)
      # need to prevent the addition of a :filters key entirely in order
      # to detect --no-filters, which shows up as :filters=>nil.
      if options[:filters]
        options[:filters] = options[:filters].split(/\s*,\s*/)
      end

      XmlEmitter.new(configuration, filename, options).emit_xml
    end

    desc 'etl', 'Performs the full extract-transform-load process for this configuration'
    long_desc <<-DESC
Clears the working schema and repopulates it with the results of running
the all the configured transforms. If the transforms are successful, the
reporting schema is wiped and replaced with the results.
DESC
    method_option 'force', :type => 'boolean',
      :desc => 'Copy the working schema to production even if there are errors'
    method_option 'preserve', :type => 'boolean',
      :desc => 'Do not wipe the working database before beginning ETL (for debugging)'
    method_option 'drop_not_null', :type => 'boolean',
      :desc => 'Drop NOT NULL constraints for all but the primary key columns in the database'
    def etl
      db = DatabaseInitializer.new(configuration)
      db.set_up_repository(:both)
      db.replace_schema unless options[:preserve]
      db.drop_all_null_constraints(:working) if options[:drop_not_null]

      success = TransformLoad.new(configuration).run
      if success || options['force']
        db.clone_working_to_reporting or exit(1)
      else
        configuration.shell.say_line "There were errors during ETL. Reporting database not updated."
        configuration.shell.say_line "See the log and the database table wh_transform_error for more details."

        exit 1
      end
    end

    desc 'count', 'Prints record counts for a warehouse instance'
    method_option 'working', :type => :boolean, :default => false,
      :desc => 'Count for the working database instead of reporting'
    method_option 'include-empty', :type => :boolean, :default => false,
      :desc => 'Includes counts for all tables, including empty ones'
    def count
      db = DatabaseInitializer.new(configuration)
      db.set_up_repository(options['working'] ? :working : :reporting)

      configuration.shell.clear_line_then_say("Loading MDES models...")
      configuration.models_module

      configuration.shell.clear_line_then_say("Counting...")
      counts = configuration.models_module.mdes_order.
        collect { |model| [model.mdes_table_name, model.count] }
      unless options['include-empty']
        counts.reject! { |table, count| count == 0 }
      end

      if counts.empty?
        configuration.shell.clear_line_and_say("All tables empty.\n")
        exit 1
      else
        max_lengths = counts.inject([0, 0]) { |lengths, row|
          lengths.zip(row.collect { |e| e.to_s.size }).collect { |sizes| sizes.max }
        }
        configuration.shell.clear_line_and_say('')
        counts.each do |table_name, count|
          configuration.shell.say_line "%#{max_lengths[0]}s %d" % [table_name, count]
        end
      end
    end

    desc 'compare', 'Compares the contents of two warehouses, A & B.'
    long_desc <<-DESC
Compares the contents of the MDES tables in two warehouses.

The comparison can be done at three levels:

1. Record counts.

2. IDs. (Which record IDs appear in one warehouse and not the other?)

3. Full contents. (Matching records based on ID, what variables have different values?)

Each level includes the one before it (i.e., doing a full content
comparison also does ID and count comparisons). Higher levels skip
tables which would add heat without light; i.e., level 2 only compares
IDs for a table when there are at least some records in each warehouse
and level 3 only compares content for tables where there are some
overlapping IDs.
DESC
    method_option 'warehouse-a', :type => :string, :aliases => %w(-a),
      :desc => 'The configuration file for warehouse A. The environment default will be used if not specified.'
    method_option 'warehouse-b', :type => :string, :required => true, :aliases => %w(-b),
      :desc => 'The configuration file for warehouse B.'
    method_option 'level', :type => :numeric, :default => 3,
      :desc => 'The level of detail for the comparison.'
    def compare
      if options['warehouse-a']
        options['config'] = options['warehouse-a']
      end
      config_a = configuration
      config_b = Configuration.from_file(options['warehouse-b'])

      Comparator.new(config_a, config_b, options).compare
    end
  end
end

