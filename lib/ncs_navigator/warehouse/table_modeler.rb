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

    def initialize(tables, options={})
      @tables = tables
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

        TableModeler.new(mdes.transmission_tables, :module => module_name, :path => options[:path])
      end

      private

      VERSION_CHAR_TO_MODULE_NAME_PART = {
        '.' => 'Point'
      }.merge(
        Hash[(0..9).to_a.collect(&:to_s).zip(%w(Zero One Two Three Four Five Six Seven Eight Nine))]
      )

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
        parts = module_name.split('::')
        f.puts(
          parts.collect { |p| "module #{p};" }.join(' ') + ' ' + parts.collect { "end;" }.join(' '))

        f.puts
        @generated_requires.each do |fn|
          f.puts "require '#{fn}'"
        end

        f.puts
        f.puts '::DataMapper.finalize'
      end
    end

    def model_template
      @model_template ||= ERB.new(File.read(template_path), nil, '-')
    end

    def template_path
      @template_path ||= File.expand_path('../table_modeler/model_template.rb.erb', __FILE__)
    end
  end
end
