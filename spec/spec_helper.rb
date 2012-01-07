require 'rspec'
require 'fakefs/spec_helpers'

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'ncs_navigator/warehouse'
require 'ncs_navigator/configuration'

$LOAD_PATH.push File.expand_path('..', __FILE__)

require 'global_state_helper'

require 'dm-core'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  ##
  # A mostly-default configuration to use in tests of objects that
  # rely on the MDES specification so as to avoid initializing it
  # multiple times. It also contains the configuration pointing to the
  # test database schemas.
  def spec_config
    @spec_config || fail("Flag specs that use spec_config with :use_mdes or :use_database")
  end

  def init_spec_config
    @spec_config ||= NcsNavigator::Warehouse::Configuration.new.tap do |c|
      c.mdes_version = spec_mdes_version
      c.output_level = :quiet
      c.log_file = tmpdir + 'spec.log'
      c.bcdatabase_group = ENV['CI_RUBY'] ? :public_ci_postgresql9 : :local_postgresql
      c.bcdatabase_entries[:working] = :mdes_warehouse_working_test
      c.bcdatabase_entries[:reporting] = :mdes_warehouse_reporting_test
    end
  end

  ###### MDES model loading

  # Each test run can only operate against one version of the MDES at
  # a time. When the system supports more than one version, the CI
  # build should be set up to run with this environment variable set
  # with each supported version.
  def spec_mdes_version
    ENV['SPEC_MDES_VERSION'] || NcsNavigator::Warehouse::DEFAULT_MDES_VERSION
  end

  config.before(:each, :use_mdes) do
    init_spec_config
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

  ###### use_database

  config.before(:each, :use_database) do
    init_spec_config

    $db_init ||=
      begin
        init = NcsNavigator::Warehouse::DatabaseInitializer.new(spec_config)
        init.set_up_repository(:both)
        init.replace_schema
        init.clone_working_to_reporting
      end
  end

  config.after(:each, :use_database) do
    DataMapper.repository.adapter.execute("SET client_min_messages = warning")
    ::DataMapper::Model.descendants.each do |model|
      begin
        DataMapper.repository.adapter.execute("TRUNCATE TABLE #{model.storage_name} CASCADE")
      rescue DataObjects::SyntaxError
        # table was never created
      end
    end
  end

  ###### bcdatabase

  config.before(:each, :use_test_bcdatabase) do
    use_test_bcdatabase
  end

  def use_test_bcdatabase
    fail 'Use :modifies_warehouse_state with use_test_database' unless @global_state_preserver
    NcsNavigator::Warehouse.bcdatabase =
      Bcdatabase.load(File.expand_path('../bcdatabase', __FILE__), :transforms => [:datamapper])
  end

  ###### tmpdir

  config.after do
    @tmpdir.rmtree if @tmpdir && !ENV['KEEP_TMP']
  end

  # @return [Pathname] the path to an existing temporary director
  def tmpdir(*path)
    @tmpdir = Pathname.new(File.expand_path('../../tmp', __FILE__)).
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
