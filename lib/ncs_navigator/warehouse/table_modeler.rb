require 'fileutils'
require 'active_support/core_ext/string'

require 'ncs_navigator/mdes'
require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/table_modeler/mdes_ext'

module NcsNavigator::Warehouse
  class TableModeler
    attr_reader :path
    attr_reader :module_name
    attr_reader :tables
    attr_reader :mdes_version
    attr_reader :mdes_specification_version

    def initialize(tables, version_string, specification_version_string, options={})
      @tables = tables
      @mdes_version = version_string
      @mdes_specification_version = specification_version_string
      @module_name = options.delete(:module).try(:to_s) or fail 'Please specify a target module'
      @path = options.delete(:path) or fail 'Please specify a path to which to generate the files'
      @path = File.join(path, module_name.underscore)
      @generated_files = []
      @generated_requires = []
    end

    class << self
      def for_version(version_string, options={})
        mdes = NcsNavigator::Mdes(version_string)
        module_name = [self.name.split('::')[0..-2], 'Models', version_module_name(version_string)].
          flatten.join('::')

        TableModeler.new(mdes.transmission_tables, version_string, mdes.specification_version,
          :module => module_name, :path => options[:path])
      end

      VERSION_CHAR_TO_MODULE_NAME_PART = {
        '.' => 'Point'
      }.merge(
        Hash[(0..9).to_a.collect(&:to_s).zip(%w(Zero One Two Three Four Five Six Seven Eight Nine))]
      )

      ##
      # @return [String] the name of the module to use or create for the given version.
      def version_module_name(version_string)
        version_string.split('').collect { |c| VERSION_CHAR_TO_MODULE_NAME_PART[c] }.join('')
      end
    end

    def model!
      load!
      ::DataMapper.finalize
    end

    def load!
      generate!
      @generated_files.each { |f| load f }
    end

    def generate!
      FileUtils.mkdir_p path

      generate_models!
      generate_main_library_file!
    end

    private

    def generate_models!
      tables.collect do |t|
        filename = File.join(path, "#{t.name}.rb")
        File.open(filename, 'w') do |f|
          f.write model_template.result(binding)
        end
        @generated_files << filename
        @generated_requires << File.join(module_name.underscore, t.name)
      end
    end

    def generate_main_library_file!
      File.open("#{path}.rb", 'w') do |f|
        f.puts(generate_code_in_module do
          'extend NcsNavigator::Warehouse::Models::MdesModelCollection'
        end)

        f.puts
        @generated_requires.each do |fn|
          f.puts "require '#{fn}'"
        end

        f.puts
        f.puts(generate_code_in_module do
          "mdes_version #{mdes_version.inspect}\n" +
          "mdes_specification_version #{mdes_specification_version.inspect}\n" +
          "mdes_order #{tables.collect(&:wh_model_name).join(",\n  ")}"
        end)

        f.puts
        f.puts '::DataMapper.finalize'
      end
    end

    def generate_code_in_module(indent='  ')
      s = ''
      parts = module_name.split('::')
      s <<
        parts.each_with_index.collect { |p, i|
        "#{indent * i}module #{p}"
      }.join("\n")

      full_indent = "\n#{indent * parts.size}"
      s << full_indent << yield.split("\n").join(full_indent) << "\n"

      s <<
        parts.each_with_index.collect { |p, i|
        "#{indent * (parts.size - i - 1)}end"
      }.join("\n")
    end

    def model_template
      @model_template ||= ERB.new(File.read(template_path), nil, '-')
    end

    def template_path
      @template_path ||= File.expand_path('../table_modeler/model_template.rb.erb', __FILE__)
    end
  end
end
