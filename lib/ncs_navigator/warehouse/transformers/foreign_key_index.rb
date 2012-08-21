require 'ncs_navigator/warehouse'
require 'set'

module NcsNavigator::Warehouse::Transformers
  ##
  # Provides for in-memory reporting of foreign key violations during
  # ETL runs.
  #
  # When FK constraint violations are delegated to the database, only
  # one can be reported per ETL execution. This class (or one like it)
  # allows for all foreign key violations to be reported across an
  # entire run.
  #
  # @see Configuration#foreign_key_index
  class ForeignKeyIndex
    autoload :DatabaseKeyProvider, 'ncs_navigator/warehouse/transformers/foreign_key_index/database_key_provider'
    autoload :StaticKeyProvider,   'ncs_navigator/warehouse/transformers/foreign_key_index/static_key_provider'

    ##
    # The object that will be used to pre-initialize the known keys list for
    # a particular model. It has a single method (`existing_keys`) which takes
    # a single argument, the model class for which keys should be provided, and
    # returns an array of the known keys for that model.
    #
    # `existing_keys` will be called at most once for each model class. It will
    # be called the first time either a record of the model's type is
    # encountered or the first time a foreign key of the model's type is
    # encountered.
    #
    # @return [#existing_keys]
    attr_reader :existing_key_provider

    ##
    # @param [Hash<Symbol, Object>] options
    # @option options [#existing_keys] :existing_key_provider (an instance of DatabaseKeyProvider)
    #   See {#existing_key_provider} for more information.
    def initialize(options={})
      @existing_key_provider = if options.has_key?(:existing_key_provider)
        options[:existing_key_provider] || StaticKeyProvider.new # empty if nil
      else
        DatabaseKeyProvider.new
      end
      @seen_keys = {}
    end

    ##
    # Records the key for this record in the index and verifies its
    # foreign keys. If any are not satisfied, they will be stored for
    # later evaluation.
    #
    # @param [DataMapper::Resource] record the record whose key we
    #   want to record and whose foreign references we want to verify.
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
    #
    # Each failed reference will be reported by this method only
    # once. This is so that it is safe to share a single instance of
    # this class across multiple transformers, reporting only the
    # newly encountered errors for each transform in turn.
    #
    # @return [void]
    # @param [TransformStatus] transform_status
    def report_errors(transform_status)
      interim_unsatisfied.each do |relationship_instance|
        if !seen?(relationship_instance.foreign_model, relationship_instance.reference_value)
          transform_status.transform_errors << relationship_instance.create_error
        end
      end
      interim_unsatisfied.clear
    end

    ##
    # @return [Boolean] has the index seen a record of the given type with the
    #   given ID.
    def seen?(model_class, id)
      seen_keys(model_class).include?(id)
    end

    private

    def verify_relationship(record, belongs_to)
      reference_name  = belongs_to.child_key.first.name
      reference_value = record.send(reference_name)
      foreign_model   = belongs_to.parent_model

      if reference_value && !seen?(foreign_model, reference_value)
        interim_unsatisfied << RelationshipInstance.new(
          record.key.first, record.class.to_s, foreign_model, reference_name, reference_value
        )
      end
    end

    def seen_keys(model_class)
      @seen_keys[model_class.to_s] ||= begin
        existing_keys = existing_key_provider.existing_keys(model_class) || []
        Set.new(existing_keys)
      end
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
