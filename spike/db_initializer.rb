require 'bcdatabase'
require 'data_mapper'
require 'benchmark'

require 'dm-constraints/adapters/dm-do-adapter'

# Reopen to add DEFERRABLE
module DataMapper::Constraints::Adapters::DataObjectsAdapter::SQL
  private

  # From dm-constraints. TODO: make this properly configurable
  def create_constraints_statement(storage_name, constraint_name, constraint_type, foreign_keys, reference_storage_name, reference_keys)
    DataMapper::Ext::String.compress_lines(<<-SQL)
              ALTER TABLE #{quote_name(storage_name)}
              ADD CONSTRAINT #{quote_name(constraint_name)}
              FOREIGN KEY (#{foreign_keys.join(', ')})
              REFERENCES #{quote_name(reference_storage_name)} (#{reference_keys.join(', ')})
              ON DELETE #{constraint_type}
              ON UPDATE #{constraint_type}
              DEFERRABLE INITIALLY DEFERRED
            SQL
  end
end

class DatabaseInitializer
  def bcdb
    @bcdb ||= Bcdatabase.load
  end

  def initialize(bcdatabase_group)
    @bcdatabase_group = bcdatabase_group

    DataMapper::Logger.new(File.open('datamapper.log', 'w'), :debug)
    @adapter = DataMapper.setup(:default, params.merge('adapter' => 'postgres'))

    @adapter.resource_naming_convention =
      lambda { |name| DataMapper::Inflector.underscore(DataMapper::Inflector.demodulize(name)) }
  end

  def init_schema!
    $stderr.puts(Benchmark.measure do
      $stderr.puts "Drop everything"
      DataMapper.repository(:default).adapter.execute("DROP OWNED BY #{params['username']}")
      $stderr.puts "Initialize schema"
      DataMapper.auto_migrate!
    end)
  end

  def params
    bcdb[@bcdatabase_group, :mdes_warehouse_working]
  end
end
