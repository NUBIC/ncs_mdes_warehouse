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
          prop = self.class.properties[variable_name]
          is_hidden_pii = !options[:pii] && prop.pii == true
          content =
            unless is_hidden_pii
              self.send(variable_name)
            end
          if !content && prop.options[:set]
            content = %w(-3 -6).detect { |c| prop.options[:set].include?(c) }
          end
          # Omit if blank and omittable, otherwise have a blast
          if !content.blank? || !prop.omittable
            xml.tag!(variable_name, content)
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
        self.storage_names[:default]
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
