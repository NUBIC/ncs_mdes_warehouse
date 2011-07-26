require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/table_modeler/mdes_ext'

module NcsNavigator::Warehouse
  class TableModeler
    attr_reader :path
    attr_reader :module_name

    def initialize(tables, options={})
      @tables = tables
      @path = options.delete(:path) or fail "Please specify a path to which to generate the files"
      @module_name = options.delete(:module)
      @generated_files = []
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
      @tables.each do |t|
        filename = File.join(path, "#{t.name}.rb")
        File.open(filename, 'w') do |f|
          f.write model_template.result(binding)
        end
        @generated_files << filename
      end
    end

    private

    def model_template
      @model_template ||= ERB.new(File.read(template_path), nil, '-')
    end

    def template_path
      @template_path ||= File.expand_path('../table_modeler/model_template.rb.erb', __FILE__)
    end
  end
end
