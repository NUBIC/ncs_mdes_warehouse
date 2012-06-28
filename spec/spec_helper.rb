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
    require 'spec_warehouse_config'

    @spec_config ||= NcsNavigator::Warehouse::Spec.configuration.tap do |c|
      c.output_level = :quiet
      c.log_file = tmpdir + 'spec.log'
    end
  end

  ##
  # Returns the MDES model for name.
  #
  # @param name [Symbol] an MDES table name or a warehouse model name
  # @return [Class]
  def mdes_model(name)
    begin
      spec_config.models_module.const_get(name)
    rescue NameError
      spec_config.models_module.mdes_order.find { |model| model.mdes_table_name.to_s == name.to_s }
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

  ###### use_database

  config.before(:each, :use_database) do
    $db_init ||=
      begin
        init = NcsNavigator::Warehouse::DatabaseInitializer.new(spec_config)
        init.set_up_repository(:both)
      end
  end

  config.after(:each, :use_database) do
    DataMapper.repository.adapter.execute("SET client_min_messages = warning")
    tables = ::DataMapper::Model.descendants.collect { |model| model.storage_name }
    begin
      DataMapper.repository.adapter.execute("TRUNCATE TABLE #{tables.join(', ')} CASCADE")
    rescue DataObjects::SyntaxError
      # table was never created
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
    # Not sure how the tmpdir could be gone if the instance var is
    # set, but it seems to happen in CI sometimes.
    @tmpdir.rmtree if (@tmpdir && @tmpdir.exist? && !ENV['KEEP_TMP'])
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
