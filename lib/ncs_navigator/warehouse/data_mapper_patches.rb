# Monkey patches for DataMapper components.

######
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

######
# Disable humanizing in DM. The table and variable names in the MDES are known
# to users of the system by their actual underscored names, so humanizing is
# counterproductive.
#
# This implementation is a bit of a nuclear option, but the other options are:
#
# * Use custom validation messages for all validations.
# * Interrupt humanizing the validators specifically.
#
# There's no reason why we ever want humanizing to happen, so I think this is
# best.

require 'dm-core/support/inflector/inflections'

# @private
module DataMapper::Inflector
  def humanize(lower_case_and_underscored_word)
    lower_case_and_underscored_word
  end
end

# TODO: add/verify there are specs to ensure this does not break the
#       behavior of mdes-wh without --soft_validations
#
# This hack is added to get around DataMapper validating :required =>
# true in dm-core. With dm-validations :required => true is also
# validated but the validation in dm-core cannot be disabled using
# save! (or any other known method)
class DataMapper::Property
  def valid?(*args)
    true
  end
end
