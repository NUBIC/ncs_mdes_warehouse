require 'ncs_navigator/warehouse'
require 'set'

module NcsNavigator::Warehouse::Transformers
  class ForeignKeyIndex
    def initialize
      @seen_keys = {}
    end

    ##
    # Records the key for this record in the index and verifies its
    # foreign keys. If any are not satisfied, they will be stored for
    # later evaluation.
    #
    # @return [void]
    def record_and_verify(record)
      seen_keys(record.class) << record.key.first # no CPKs in MDES

      record.class.relationships.each do |belongs_to|
        verify_relationship(record, belongs_to)
      end
    end

    ##
    # Reviews any references that initially failed against the final
    # set of keys. If any are still unresolveable, it records errors
    # against the provided transform status.
    def report_errors(transform_status)
      interim_unsatisfied.each do |relationship_instance|
        if !seen?(relationship_instance.foreign_model, relationship_instance.reference_value)
          transform_status.transform_errors << relationship_instance.create_error
        end
      end
    end

    private

    def verify_relationship(record, belongs_to)
      reference_name  = belongs_to.child_key.first.name
      reference_value = record.send(reference_name)
      foreign_model   = belongs_to.parent_model.to_s

      if reference_value && !seen?(foreign_model, reference_value)
        interim_unsatisfied << RelationshipInstance.new(
          record.id, record.class.to_s, foreign_model, reference_name, reference_value
        )
      end
    end

    def seen?(model_class, id)
      seen_keys(model_class).include?(id)
    end

    def seen_keys(model_class)
      @seen_keys[model_class.to_s] ||= Set.new
    end

    def interim_unsatisfied
      @interim_unsatisfied ||= []
    end

    ##
    # @private
    class RelationshipInstance < Struct.new(:record_id, :model_class, :foreign_model, :reference_key, :reference_value)
      def create_error
        NcsNavigator::Warehouse::TransformError.new(
          :record_id => record_id, :model_class => model_class,
          :message => "Unsatisfied foreign key #{reference_key}=#{reference_value} referencing #{foreign_model}."
        )
      end
    end
  end
end
