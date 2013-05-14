require 'ncs_navigator/warehouse'

require 'nokogiri'
require 'forwardable'

class NcsNavigator::Warehouse::Transformers::VdrXml
  ##
  # A streaming reader for MDES VDR XML-formatted files. It reads each
  # record in turn, converts it into a warehouse model instance, and
  # yields it to a provided collaborator.
  class Reader
    include Enumerable
    extend Forwardable

    attr_reader :configuration
    attr_reader :filename

    def_delegator :@configuration, :shell

    ##
    # These code values indicate missing or unknown data.
    # If one of them appears in a nullable, non-coded field, we will
    # skip it. Similarly, if a record's PK is one of these values, we
    # will skip the entire record.
    MISSING_CODES = %w(-3 -4 -6 -7)

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
      @record_count = 0
    end

    def name
      if @filename
        "VDR XML #{@filename}"
      else
        "VDR XML #{@io.inspect}"
      end
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
      shell.say_line("Reading VDR XML #{filename if filename}")
      @start = Time.now

      Nokogiri::XML::Reader(@io).each do |node|
        element_types = [:TYPE_ELEMENT, :TYPE_END_ELEMENT].
          collect { |c| Nokogiri::XML::Reader.const_get(c) }
        next unless element_types.include?(node.node_type)
        encounter_node(node, node.node_type == 1, &block)
      end

      @end = Time.now

      shell.clear_line_then_say(
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
        if !is_open && node.local_name == @current_model_class.mdes_table_name
          # on the way out of this record
          yield build_current_instance
          @current_model_class = nil
          @record_count += 1
          shell.clear_line_then_say('%6d records (%3.1f per second); up to %s' %
            [@record_count, load_rate, node.local_name])
        else
          # node is the start tag of a table variable
          var = node.local_name.to_sym

          val =
            if node.attribute('xsi:nil') == 'true'
              nil
            elsif !node.self_closing?
              child = node.read
              child.value? ? child.value.strip.gsub('&#13;', "\r") : ''
            end

          unless node.self_closing?
            # Skip to closing tag
            until node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT
              node.read
            end
          end

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
    end

    def is_foreign_key_in_current_model?(variable_name)
      @current_model_class.relationships.
        detect { |r| r.child_key.collect(&:name).include?(variable_name) }
    end
    private :is_foreign_key_in_current_model?

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
