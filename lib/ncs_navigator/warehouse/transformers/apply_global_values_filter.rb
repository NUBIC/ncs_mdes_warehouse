require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  ##
  # A filter which sets certain variables to the same values on all
  # records if those variables are not already set when the filter
  # encounters the records.
  #
  # This filter deliberately only supports cross-cutting static
  # values. More complex cases should be handled in a transformer.
  #
  # By default, this filter will set the following variables with
  # values taken from the Navigator suite configuration:
  #
  # * `psu_id`: set to the ID if the first PSU in the suite
  #   configuration.
  #
  # * `recruit_type`: set to the `recruitment_type_id` value from the
  #   suite configuration.
  #
  # This filter supports options and so needs to be instantiated when
  # being added to the warehouse configuration.
  class ApplyGlobalValuesFilter
    attr_reader :global_values

    ##
    # @param configuration [Configuration] the configuration context
    #   in which this filter is being used.
    # @param options [Hash<Symbol, Object>] customization options.
    # @option options :values [Hash<Symbol, Object>] variables and
    #   values which the filter will apply. This hash may override the
    #   default values (see above) and/or add others.
    def initialize(configuration, options={})
      @global_values = defaults(configuration).merge(options[:values] ||= {})
    end

    def call(records)
      records.each do |record|
        apply_global_values(record)
      end
    end

    private

    def defaults(configuration)
      {
        :psu_id => configuration.navigator.psus.first.id,
        :recruit_type => configuration.navigator.recruitment_type_id
      }
    end

    def apply_global_values(record)
      global_values.each do |attr, value|
        setter = "#{attr}="
        if record.respond_to?(setter) && record.respond_to?(attr)
          unless record.send(attr)
            record.send(setter, value)
          end
        end
      end
    end
  end
end
