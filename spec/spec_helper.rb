require 'rspec'
require 'fakefs/spec_helpers'

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'ncs_navigator/warehouse'
require 'ncs_navigator/configuration'

$LOAD_PATH.push File.expand_path('..', __FILE__)

require 'global_state_helper'

require 'data_mapper'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  ###### bcdatabase

  config.before(:all) do
    NcsNavigator::Warehouse.bcdatabase =
      Bcdatabase.load(File.expand_path('../bcdatabase', __FILE__), :transforms => [:datamapper])
  end

  ###### MDES model loading

  # Each test run can only operate against one version of the MDES at
  # a time. When the system supports more than one version, the CI
  # build should be set up to run with this environment variable set
  # with each supported version.
  def spec_mdes_version
    ENV['SPEC_MDES_VERSION'] || NcsNavigator::Warehouse::DEFAULT_MDES_VERSION
  end

  ##
  # A mostly-default configuration to use in tests of objects that
  # rely on the MDES specification so as to avoid initializing it
  # multiple times.
  def spec_config
    @spec_config || fail("Flag specs that use spec_config with :use_mdes")
  end

  config.before(:each, :use_mdes) do
    @spec_config ||= NcsNavigator::Warehouse::Configuration.new.tap do |c|
      c.mdes_version = spec_mdes_version
      c.output_level = :quiet
      c.log_file = tmpdir + 'spec.log'
    end
  end

  ###### modifies_warehouse_state

  config.before(:each, :modifies_warehouse_state) do
    @global_state_preserver = NcsNavigator::Warehouse::Spec::GlobalStatePreserver.new.save
  end

  def clear_warehouse_state
    @global_state_preserver.clear
  end

  config.after(:each, :modifies_warehouse_state) do
    @global_state_preserver.restore
  end

  ###### tmpdir

  config.after do
    @tmpdir.rmtree if @tmpdir && !ENV['KEEP_TMP']
  end

  # @return [Pathname] the path to an existing temporary director
  def tmpdir(*path)
    @tmpdir ||= Pathname.new(File.expand_path('../../tmp', __FILE__)).
      tap { |p| p.mkpath }
    if path.empty?
      @tmpdir
    else
      @tmpdir.join(*path).tap { |p| p.mkpath }
    end
  end
end

NcsNavigator.configuration =
  NcsNavigator::Configuration.new(File.expand_path('../navigator.ini', __FILE__))
