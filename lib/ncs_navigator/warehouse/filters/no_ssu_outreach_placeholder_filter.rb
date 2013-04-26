require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Filters
  ##
  # A filter which associates outreach event records that don't have
  # an SSU ID with an automatically-created placeholder SSU.
  #
  # This filter is intended for use when reading a center's VDR XML
  # into the warehouse for eventual import into a new NCS Navigator
  # instance. Some centers have outreach events which are not
  # logically associated with any SSUs. This scenario is permitted in
  # MDES 2.1+, but not in MDES 2.0. This filter provides a shim to
  # allow their data to be loaded, both into the warehouse and
  # eventually into Staff Portal. The shim will be removed after they
  # are upgraded to MDES 2.1.
  #
  # This filter is stateful and so needs to be instantiated when being
  # added to the warehouse configuration.
  class NoSsuOutreachPlaceholderFilter
    PLACEHOLDER_SSU_ID = 'NO_SSU_PLACEHOLDER_PRE_MDES_2_1'

    def initialize(configuration)
      @configuration = configuration
      @outreach_model = configuration.models_module.const_get(:Outreach)
    end

    def call(records)
      return records unless has_any_no_ssu_outreach?(records)

      unless @placeholder_ssu_created
        records.unshift(create_placeholder_ssu)
        @placeholder_ssu_created = true
      end

      records.each do |rec|
        rec.ssu_id = PLACEHOLDER_SSU_ID if is_no_ssu_outreach?(rec)
      end

      records
    end

    private

    def has_any_no_ssu_outreach?(records)
      records.detect { |r| is_no_ssu_outreach?(r) }
    end

    def is_no_ssu_outreach?(record)
      record.class == @outreach_model && record.ssu_id.nil?
    end

    def create_placeholder_ssu
      @configuration.models_module.const_get(:Ssu).new(
        :ssu_id => PLACEHOLDER_SSU_ID,
        :ssu_name => 'Placeholder SSU for no-SSU outreach events until upgraded to MDES 2.0',
        :psu_id => @configuration.navigator.psus.first.id,
        :sc_id  => @configuration.navigator.study_center_id
      )
    end
  end
end
