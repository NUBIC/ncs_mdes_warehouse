require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  class VdrXml
    autoload :Reader, 'ncs_navigator/warehouse/transformers/vdr_xml/reader'

    class << self
      ##
      # @return [#transform] a transformer that loads the MDES data in
      #   the specified VDR XML file.
      def from_file(filename)
        EnumTransformer.new(Reader.new(filename))
      end

      ##
      # @return [#transform] a transformer for the most recently
      #   modified VDR XML file from the given list of files.
      def from_most_recent_file(list)
        from_file(
          list.collect { |fn| [fn, File.stat(fn).mtime] }.
            sort_by { |fn, mtime| mtime }.reverse.first.first)
      end
    end
  end
end
