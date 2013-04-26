require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Filters
  ##
  # A filter which duplicates outreach event records that don't have
  # an SSU ID across all of a center's SSUs.
  #
  # This filter is intended for use when reading a center's VDR XML
  # into the warehouse for eventual import into a new NCS Navigator
  # instance. Some centers have outreach events which are not
  # associated with any SSUs in their XML. They intend this in
  # indicate that the outreach events are associated with all the
  # center's SSUs. This filter makes that happen.
  #
  # This filter is stateful and so needs to be instantiated when being
  # added to the warehouse configuration.
  class NoSsuOutreachAllSsusFilter
    attr_reader :ssu_ids

    ##
    # @param configuration [Configuration] the warehouse
    #   configuration.
    # @param options [Hash<Symbol, Object>]
    # @option options [Array<String>] :ssu_ids by default, full set of
    #   SSU IDs is derived from the navigator suite configuration. It
    #   can be overridden with this option.
    def initialize(configuration, options={})
      @configuration = configuration
      @ssu_ids = options[:ssu_ids] || default_ssu_ids

      @outreach_model = configuration.models_module.const_get(:Outreach)
      @outreach_associated_models = configuration.models_module.mdes_order.select { |model|
        model.relationships.detect { |rel| rel.parent_model == @outreach_model }
      }

      @replicated_outreach_event_ids = {}
    end

    def call(records)
      [].tap do |result|
        records.each do |rec|
          if is_no_ssu_outreach?(rec)
            result.concat replicate_outreach_across_ssus(rec)
          elsif is_replicated_oe_associate?(rec)
            result.concat replicate_associated_record(rec)
          else
            result << rec
          end
        end
      end
    end

    private

    def default_ssu_ids
      @configuration.navigator.ssus.collect(&:id)
    end

    def is_no_ssu_outreach?(record)
      record.class == @outreach_model && record.ssu_id.nil?
    end

    def is_replicated_oe_associate?(record)
      @outreach_associated_models.include?(record.class) &&
        @replicated_outreach_event_ids.keys.include?(record.outreach_event_id)
    end

    def replicate_outreach_across_ssus(outreach_event)
      oe_id = outreach_event.outreach_event_id

      replica_ids = ssu_ids.collect { |ssu_id| [ssu_id, create_replica_id(oe_id, ssu_id)] }

      @replicated_outreach_event_ids[oe_id] = replica_ids

      replica_ids.collect { |ssu_id, replica_oe_id|
        outreach_event.class.new(
          outreach_event.attributes.
            merge(:ssu_id => ssu_id, :outreach_event_id => replica_oe_id)
        )
      }
    end

    def create_replica_id(base_id, ssu_id)
      [base_id, ssu_id].join('-')
    end

    def replicate_associated_record(record)
      replica_oe_ids = @replicated_outreach_event_ids[record.outreach_event_id]

      associated_key_name = record.class.key.first.name

      replica_oe_ids.collect { |ssu_id, replica_oe_id|
        record.class.new(
          record.attributes.merge(
            :outreach_event_id => replica_oe_id,
            associated_key_name => create_replica_id(record.key.first, ssu_id)
          )
        )
      }
    end
  end
end
