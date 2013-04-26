require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  ##
  # Record filters and related.
  module Filters
    autoload :CompositeFilter, 'ncs_navigator/warehouse/filters/composite_filter'

    autoload :ApplyGlobalValuesFilter,        'ncs_navigator/warehouse/filters/apply_global_values_filter'
    autoload :CodedAsMissingFilter,           'ncs_navigator/warehouse/filters/coded_as_missing_filter'
    autoload :NoBlankForeignKeysFilter,       'ncs_navigator/warehouse/filters/no_blank_foreign_keys_filter'
    autoload :NoSsuOutreachAllSsusFilter,     'ncs_navigator/warehouse/filters/no_ssu_outreach_all_ssus_filter'
    autoload :NoSsuOutreachPlaceholderFilter, 'ncs_navigator/warehouse/filters/no_ssu_outreach_placeholder_filter'
  end
end
