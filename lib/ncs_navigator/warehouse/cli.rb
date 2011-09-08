require 'ncs_navigator/warehouse'

require 'thor'

module NcsNavigator::Warehouse
  class CLI < Thor
    desc 'create-schema', '(Re)builds the schema in the working database'
    def create_schema
      # TODO: this should be configurable somehow
      require 'ncs_navigator/warehouse/models/two_point_zero'

      db = DatabaseInitializer.new
      db.set_up_repository(:working)
      db.replace_schema
    end
    map 'create-schema' => 'create_schema'
  end
end

