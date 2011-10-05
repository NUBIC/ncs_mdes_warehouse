require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  class VdrXml
    autoload :Reader, 'ncs_navigator/warehouse/transformers/vdr_xml/reader'

    class << self
      def from_file(filename)
        EnumTransformer.new(Reader.new(filename))
      end

      def from_most_recent_file(list)
        from_file(
          list.collect { |fn| [fn, File.stat(fn).mtime] }.
            sort_by { |fn, mtime| mtime }.reverse.first.first)
      end
    end
  end
end
