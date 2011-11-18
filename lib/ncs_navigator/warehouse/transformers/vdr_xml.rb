require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  class VdrXml
    autoload :Reader, 'ncs_navigator/warehouse/transformers/vdr_xml/reader'

    class << self
      ##
      # @return [#transform] a transformer that loads the MDES data in
      #   the specified VDR XML file.
      def from_file(config, filename) # <- TODO better solution
        EnumTransformer.new(config, Reader.new(config, filename))
      end

      ##
      # @param config [Configuration] the configuration for the
      #   warehouse.
      # @param list [String,Array<String>] the files to consider. This
      #   may be either a glob or an explicit list of files.
      #
      # @return [#transform] a transformer for the most recently
      #   modified VDR XML file from the given list of files.
      def from_most_recent_file(config, list)
        files =
          if String === list
            Dir[list].tap { |a| fail "Glob #{list} does not match any files." if a.empty? }
          else
            list.tap { |a| fail "The file list is empty." if a.empty? }
          end

        from_file(
          config,
          files.collect { |fn| [fn, File.stat(fn).mtime] }.
            sort_by { |fn, mtime| mtime }.reverse.first.first)
      end
    end
  end
end
