require 'ncs_navigator/warehouse'

require 'nokogiri'

class NcsNavigator::Warehouse::Transformers::VdrXml
  ##
  # A streaming reader for MDES VDR XML-formatted files. It reads each
  # record in turn, converts it into a warehouse model instance, and
  # yields it to a provided collaborator.
  class Reader
    include Enumerable

    attr_reader :configuration
    attr_reader :filename

    ##
    # @return [Fixnum] the number of records that have been read so far.
    attr_reader :record_count

    def initialize(config, filename_or_io, options={})
      @configuration = config
      @filename, @io = case filename_or_io
                       when String
                         [filename_or_io, File.open(filename_or_io)]
                       else
                         [nil, filename_or_io]
                       end
      @shell = options[:quiet] ?
        NcsNavigator::Warehouse::UpdatingShell::Quiet.new :
        NcsNavigator::Warehouse::UpdatingShell.new($stderr)
      @record_count = 0
    end

    ##
    # Reads the XML and yields each encountered record as a warehouse
    # model instance to the provided block. It does not validate the
    # records and only performs minimal transformation (chiefly
    # removing foreign key values which actually indicate a missing
    # child record).
    #
    # @yield a series of model instances
    # @return [void]
    def each(&block)
      @shell.say_line("Beginning VDR XML read#{" of #{filename}" if filename}")
      @start = Time.now

      Nokogiri::XML::Reader(@io).each do |node|
        # 1 is an open element, 15 is a close
        next unless [1, 15].include?(node.node_type)
        encounter_node(node, node.node_type == 1, &block)
      end

      @end = Time.now

      @shell.clear_line_then_say(
        "Completed read of %6d records in %d seconds (%3.1f per second)\n" %
        [@record_count, load_time, load_rate])
    ensure
      @io.close if filename
    end

    private

    def encounter_node(node, is_open, &block)
      if node.local_name == 'transmission_tables'
        @in_table_section = is_open
      elsif @current_model_class
        if node.local_name == @current_model_class.mdes_table_name
          # on the way out of this record
          yield build_current_instance
          @current_model_class = nil
          @record_count += 1
          @shell.clear_line_then_say('%6d records (%3.1f per second); up to %s' %
            [@record_count, load_rate, node.local_name])
        else
          # node is the start tag of a table variable
          var = node.local_name.to_sym
          val = node.inner_xml.strip
          node.read # skip contents (read as 'var' above)
          node.read # skip close tag

          unless should_filter_out(@current_model_class, var, val)
            @current_parameter_values[var] = val
          end
        end
      elsif @in_table_section && is_open
        # in tables, but no current model, means this node is the
        # opening tag of a new table record
        @current_model_class = configuration.models_module.mdes_order.
          detect { |model| model.mdes_table_name == node.local_name }
        fail "Could not find model for #{node.local_name.inspect}" unless @current_model_class
        @current_parameter_values = {}
      end
    end

    def should_filter_out(model_class, variable_name, value)
      return true if variable_name == :transaction_type
      # if it's a key to another table...
      if @current_model_class.relationships.detect { |r| r.child_key.collect(&:name).include?(variable_name) }
        # ...and it is unknown or empty
        return value == '-3' || value.strip.empty?
      end
    end

    def build_current_instance
      @current_model_class.new(@current_parameter_values)
    end

    def load_time
      (@end || Time.now) - @start
    end

    def load_rate
      @record_count / load_time.to_f
    end
  end
end