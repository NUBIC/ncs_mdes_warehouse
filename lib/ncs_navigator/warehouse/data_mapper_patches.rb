# Monkey patches for DataMapper components.

# Make all constraints deferrable. A configurable version of this has
# been submitted to the dm-constraints:
# https://github.com/datamapper/dm-constraints/pull/13

require 'ncs_navigator/warehouse/data_mapper'
require 'data_mapper/constraints/adapters/do_adapter'
# @private
module DataMapper::Constraints::Adapters::DataObjectsAdapter::SQL
  private

  def create_constraints_statement(constraint_name, constraint_type, source_storage_name, source_keys, target_storage_name, target_keys)
    DataMapper::Ext::String.compress_lines(<<-SQL)
      ALTER TABLE #{quote_name(source_storage_name)}
      ADD CONSTRAINT #{quote_name(constraint_name)}
      FOREIGN KEY (#{source_keys.join(', ')})
      REFERENCES #{quote_name(target_storage_name)} (#{target_keys.join(', ')})
      ON DELETE #{constraint_type}
      ON UPDATE #{constraint_type}
      DEFERRABLE INITIALLY DEFERRED
    SQL
  end
end
