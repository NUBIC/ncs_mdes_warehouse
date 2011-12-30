require 'ncs_navigator/warehouse'

require 'forwardable'

module NcsNavigator::Warehouse::Transformers
  ##
  # An enumerator that yields the sampling unit records implied by the
  # current `NcsNavigator::Configuration`.
  #
  # @see Configuration#navigator
  class SamplingUnits
    include Enumerable
    extend Forwardable

    attr_reader :configuration
    def_delegators :configuration, :shell, :log

    def self.create_transformer(config)
      EnumTransformer.new(config, new(config))
    end

    def initialize(config)
      @configuration = config
    end

    def each
      log.info("Generating MDES records for sampling units.")

      shell_describe('Study Center', 1)
      yield create_study_center

      shell_describe('PSU', configuration.navigator.psus.size)
      configuration.navigator.psus.each do |nav_psu|
        yield create_psu(nav_psu)
      end

      shell_describe('SSU', configuration.navigator.ssus.size)
      configuration.navigator.ssus.each do |nav_ssu|
        yield create_ssu(nav_ssu)
      end

      tsus = configuration.navigator.ssus.collect { |nav_ssu| nav_ssu.tsus }.flatten
      shell_describe('TSU', tsus.size)
      tsus.each do |nav_tsu|
        yield create_tsu(nav_tsu)
      end

      log.info("Sampling unit records complete.")
      shell.clear_line_then_say("Sampling unit records complete.\n")
    end

    private

    def shell_describe(what, count)
      plural = ('s' if count != 1)
      shell.clear_line_then_say("Generating MDES record#{plural} for #{count} #{what}#{plural}")
    end

    def code_label(type_name, value)
      configuration.mdes.types.detect { |t| t.name == type_name }.code_list.
        detect { |code| code.value == value }.label
    end

    def model(name)
      configuration.models_module.const_get(name)
    end

    def create_study_center
      model(:StudyCenter).new(
        :sc_id => configuration.navigator.sc_id,
        :sc_name => code_label('study_center_cl1', configuration.navigator.sc_id)
      )
    end

    def create_psu(nav_psu)
      model(:Psu).new(
        :psu_id => nav_psu.id,
        :sc_id => configuration.navigator.sc_id,
        :recruit_type => configuration.navigator.recruitment_type_id,
        :psu_name => code_label('psu_cl1', nav_psu.id)
      )
    end

    def create_ssu(nav_ssu)
      model(:Ssu).new(
        :ssu_id => nav_ssu.id,
        :ssu_name => nav_ssu.name,
        :psu_id => nav_ssu.psu.id,
        :sc_id => configuration.navigator.sc_id
      )
    end

    def create_tsu(nav_tsu)
      model(:Tsu).new(
        :tsu_id => nav_tsu.id,
        :tsu_name => nav_tsu.name,
        :psu_id => nav_tsu.ssu.psu.id,
        :sc_id => configuration.navigator.sc_id
      )
    end
  end
end
