# Monkey patches for DataMapper components.

# Make all constraints deferrable. A configurable version of this has
# been submitted to the dm-constraints:
# https://github.com/datamapper/dm-constraints/pull/13

require 'dm-constraints/adapters/dm-do-adapter'
module DataMapper::Constraints::Adapters::DataObjectsAdapter::SQL
  private

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
