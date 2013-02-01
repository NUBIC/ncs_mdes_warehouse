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
      @current_transform_tracker = nil
    end

    ##
    # Indicates the beginning of a new transform. This method must be called
    # before the first time {#verify_or_defer} is called for a particular transform.
    #
    # Error reporting and deferred foreign key resolution are scoped to a
    # transform.
    def start_transform(transform_status)
      if @current_transform_tracker
        fail "#start_transform called before previous transform's #end_transform called. This will lose deferred records."
      else
        @current_transform_tracker = TransformTracker.new(transform_status)
      end
    end

    ##
    # Indicates whether a record's foreign keys can immediately be satisfied. If
    # not, it stores the record for processing in and possible return from
    # {#end_transform}.
    #
    # @param [DataMapper::Resource] record the record whose foreign references
    #   we want to verify.
    # @return [Boolean]
    def verify_or_defer(record)
      deferrer = DeferredRecord.create_if_appropriate(record, self)
      if deferrer
        @current_transform_tracker.defer(deferrer)
        false
      else
        true
      end
    end

    ##
    # Records the key for this record in the index. By calling this method,
    # the caller affirms that the record should be considered available for
    # resolution of future foreign keys.
    #
    # @param [DataMapper::Resource] record the record whose key we
    #   want to record.
    # @return [void]
    def record(record)
      seen_keys(record.class) << record.key.first # no CPKs in MDES
    end

    ##
    # Reviews any references that initially failed against the final
    # set of keys. If any are still unresolvable, it records errors
    # against the provided transform status.
    #
    # Each failed reference will be reported by this method only
    # once. This is so that it is safe to share a single instance of
    # this class across multiple transformers, reporting only the
    # newly encountered errors for each transform in turn.
    #
    # @return [Array<DataMapper::Resource>] any records which were previously
    #   deferred but which now are fully resolved and are candidates to be
    #   persisted.
    def end_transform
      fail "No current transform" unless @current_transform_tracker
      @current_transform_tracker.end_it(self).tap do |x|
        @current_transform_tracker =  nil
      end
    end

    ##
    # @return [Boolean] has the index seen a record of the given type with the
    #   given ID.
    def seen?(model_class, id)
      seen_keys(model_class).include?(id)
    end

    private

    def seen_keys(model_class)
      @seen_keys[model_class.to_s] ||= begin
        existing_keys = existing_key_provider.existing_keys(model_class) || []
        Set.new(existing_keys)
      end
    end

    ##
    # @private
    class TransformTracker
      def initialize(transform_status)
        @transform_status = transform_status
        @deferred_records = []
      end

      def defer(deferred_record)
        @deferred_records << deferred_record
      end

      def end_it(fk_index)
        update_satisfied_by_for_deferred(fk_index)
        build_deferred_graph
        compute_record_resolvabilities

        deferred_satisfied, deferred_unsatisfied = partition_deferred

        deferred_unsatisfied.each { |deferred_record| deferred_record.report_errors(@transform_status) }

        deferred_satisfied.collect(&:record)
      end

      private

      def update_satisfied_by_for_deferred(fk_index)
        @deferred_records.each do |deferred_record|
          deferred_record.update_satisfied_by_for_relationships(fk_index, @deferred_records)
        end
      end

      def build_deferred_graph
        require 'rgl/base'
        require 'rgl/adjacency'
        require 'rgl/connected_components'
        require 'rgl/condensation'

        @graph = RGL::DirectedAdjacencyGraph.new
        @deferred_records.each do |rec|
          rec.deferred_relationships.each do |rel|
            @graph.add_edge(rec, rel.satisfied_by)
          end
        end
      end

      def compute_record_resolvabilities
        # scc == strongly connected component; i.e., a single record or a complete cycle
        @graph.condensation_graph.depth_first_search do |scc|
          # skip the special terminal nodes :unsatisfed and :already_saved
          next if Symbol === scc.first

          # find all the external deferred relationships for the SCC
          external_relationships = scc.collect { |rec|
            rec.deferred_relationships.reject { |dr| scc.include?(dr.satisfied_by) }
          }.flatten

          # combine the resolvabilities for those those to determine the resolvability for the SCC
          net_resolvability = external_relationships.collect(&:resolvable?).
            reject { |r| r }.empty? # are there any false ones?

          # update each DeferredRecord with the determined resolvability for the SCC
          scc.each do |rec|
            rec.resolvability = net_resolvability
          end
        end
      end

      def partition_deferred
        @deferred_records.partition { |rec| rec.resolvable? }
      end
    end

    ##
    # @private
    #
    # These track records which are pending until the end of the transform
    # and then are used as vertices in the graph which is used for analyzing
    # remaining unsatisfied relationships.
    class DeferredRecord
      attr_reader :record, :deferred_relationships

      ##
      # The externally determined total resolvability for this record.
      # @see TransformTracker#compute_record_resolvabilities
      attr_writer :resolvability

      ##
      # @return [DeferredRecord,nil] if the record has any currently unsatisfied
      #   FKs, return a properly initialized DeferredRecord.
      def self.create_if_appropriate(record, fk_index)
        relationships = record.class.relationships.collect { |belongs_to|
          DeferredRelationship.create_if_appropriate(record, belongs_to, fk_index)
        }.compact
        if relationships.empty?
          nil
        else
          DeferredRecord.new(record, relationships)
        end
      end

      def initialize(record, deferred_relationships)
        @record = record
        @deferred_relationships = deferred_relationships
      end

      def model_class
        record.class.to_s
      end

      def record_id
        record.key.first
      end

      def update_satisfied_by_for_relationships(fk_index, deferred_pool)
        deferred_relationships.each do |rel|
          rel.update_satisfied_by(fk_index, deferred_pool)
        end
      end

      def resolvability_determined?
        !@resolvability.nil?
      end

      def resolvable?
        unless resolvability_determined?
          fail "Graph iteration failure: DR #{self} #resolvable? called before resolvability determined."
        end
        @resolvability
      end

      def report_errors(transform_status)
        deferred_relationships.collect { |rel| rel.create_error }.compact.each do |error|
          transform_status.transform_errors << error
        end
      end

      def to_s
        "#{model_class}##{record_id}"
      end
    end

    ##
    # @private
    class DeferredRelationship < Struct.new(:record, :foreign_model, :reference_key, :reference_value)
      def self.create_if_appropriate(record, belongs_to, fk_index)
        reference_name  = belongs_to.child_key.first.name
        reference_value = record.send(reference_name)
        foreign_model   = belongs_to.parent_model

        if reference_value && !fk_index.seen?(foreign_model, reference_value)
          DeferredRelationship.new(
            record, foreign_model, reference_name, reference_value
          )
        else
          nil
        end
      end

      attr_accessor :satisfied_by

      def initialize(*)
        super
        @satisfied_by = :unsatisfied
      end

      def record_id
        record.key.first # No CPKs in MDES
      end

      def model_class
        record.class.to_s
      end

      def update_satisfied_by(fk_index, deferred_pool)
        if seen_in?(fk_index)
          self.satisfied_by = :already_saved
        elsif satisfier = deferred_pool.find { |deferred_record| self.satisfied_by_deferred?(deferred_record) }
          self.satisfied_by = satisfier
        end
      end

      def seen_in?(fk_index)
        fk_index.seen?(foreign_model, reference_value)
      end

      def satisfied_by_deferred?(deferred_record)
        self.foreign_model.to_s == deferred_record.model_class.to_s &&
        self.reference_value == deferred_record.record_id
      end

      def create_error
        return nil if resolvable?

        message =
          case satisfied_by
          when Symbol # i.e., :unsatisfied
            "Unsatisfied foreign key referencing #{foreign_model}."
          else
            "Associated #{foreign_model} record contains one or more unsatisfed foreign keys or refers to other records that do."
          end

        NcsNavigator::Warehouse::TransformError.new(
          :record_id => record_id, :model_class => model_class,
          :attribute_name => reference_key, :attribute_value => reference_value.inspect,
          :message => message
        )
      end

      def resolvable?
        case satisfied_by
        when :unsatisfied
          false
        when :already_saved
          true
        else
          if satisfied_by.resolvability_determined?
            satisfied_by.resolvable?
          else
            # The DFS over the coalesced graph should prevent this from happening,
            # so this is a check against a programming fault or misconception.
            fail "Graph iteration failure: FK #{self} #resolvable? called before satisfying-record resolvability determined."
          end
        end
      end

      def to_s
        "#{model_class}##{record_id}.#{reference_key} => #{foreign_model}##{reference_value}"
      end
    end
  end
end
