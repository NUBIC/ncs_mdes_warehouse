require 'active_support/core_ext/string'
require 'builder'

require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Models
  ##
  # A mix-in providing special functionality for MDES-based
  # DataMapper models.
  module MdesModel
    ##
    # Writes an XML fragment for this model to the given IO stream.
    #
    # @return [void]
    def write_mdes_xml(io, options={})
      builder = Builder::XmlMarkup.new(
        :indent => options[:indent] || 2, :margin => options[:margin])
      io << builder.tag!(self.class.mdes_table_name) { |xml|
        self.class.mdes_order.each do |variable_name|
          v = self.send(variable_name)
          if v && (self.class.properties[variable_name].pii != true || options[:pii])
            xml.tag!(variable_name, v)
          end
        end
      } << "\n"
    end

    ##
    # Add the class methods, too.
    #
    # @private
    def self.included(into)
      into.extend ClassMethods
    end

    module ClassMethods
      ##
      # The name of the table in the MDES corresponding to this model.
      # @return [String]
      def mdes_table_name
        @mdes_table_name ||= self.name.demodulize.underscore
      end

      ##
      # Sets or retrieves the required property order.
      #
      # @overload mdes_order(*variable_names)
      #   Sets the output order.
      #   @param [Array<Symbol>] variables_names the order
      # @overload mdes_order
      #   Retrieves the output order.
      #
      # @return [Array<Symbol>]
      def mdes_order(*input)
        if input.empty?
          @mdes_order
        else
          @mdes_order = input
        end
      end
    end
  end
end
