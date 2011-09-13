require 'ncs_navigator/warehouse'

require 'thor'

module NcsNavigator::Warehouse
  class CLI < Thor
    class_option 'mdes-version', :type => :string, :default => DEFAULT_MDES_VERSION,
      :desc => 'The MDES version for the warehouse in use', :banner => 'X.Y'

    no_tasks {
      def use_mdes
        NcsNavigator::Warehouse.use_mdes_version(options[:'mdes-version'])
      end
    }

    desc 'create-schema', '(Re)builds the schema in the working database'
    def create_schema
      use_mdes

      db = DatabaseInitializer.new
      db.set_up_repository(:working)
      db.replace_schema
    end
    map 'create-schema' => 'create_schema'
  end
end

