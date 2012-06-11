require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  ##
  # This filter transforms any blank foreign keys into nil. Blank
  # foreign keys are a common issue in source XML data.
  #
  # This filter is stateless and so should not be instantiated when
  # added to a warehouse's configuration.
  class NoBlankForeignKeysFilter
    def self.call(records)
      records.each do |record|
        remove_missing_foreign_keys(record)
      end
    end

    private

    def self.remove_missing_foreign_keys(record)
      record.class.relationships.each do |rel|
        reference_key = rel.child_key.first.name
        reference_value = record.send(reference_key)
        if reference_value && reference_value.strip.empty?
          record.send("#{reference_key}=", nil)
        end
      end
    end
  end
end
