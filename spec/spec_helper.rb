require 'rspec'
require 'fakefs/spec_helpers'

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'ncs_navigator/warehouse'
require 'ncs_navigator/configuration'

$LOAD_PATH.push File.expand_path('..', __FILE__)

require 'global_state_helper'
require 'spec_warehouse_config'

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
      c.foreign_key_index = NcsNavigator::Warehouse::Transformers::ForeignKeyIndex.new(:existing_key_provider => nil)
    end
  end

  ##
  # Returns the MDES model for name.
  #
  # @param name [Symbol] an MDES table name or a warehouse model name
  # @return [Class]
  def mdes_model(name)
    spec_config.model(name)
  end

  ###### MDES model loading

  def spec_mdes_version
    NcsNavigator::Warehouse::Spec.mdes_version
  end

  config.before(:each, :use_mdes) do
    # Specs with :use_mdes may expect the warehouse models to be loaded
    spec_config
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

  # Other specs call set_up_repository with different warehouse configs.
  # This interferes with global state (DM's connection setup), so we need
  # to reconnect for each :use_database group to correct.
  config.before(:all, :use_database) do
    NcsNavigator::Warehouse::Spec.database_initializer(spec_config).tap do |db|
      db.set_up_repository(:both)
    end
  end

  config.after(:each, :use_database) do
    [:working, :reporting].each do |db|
      repo_name = "mdes_warehouse_#{db}".to_sym
      adapter = DataMapper.repository(repo_name).adapter
      adapter.execute("SET client_min_messages = warning")

      tables = adapter.
        select("SELECT table_name FROM information_schema.tables WHERE table_schema='public'")
      unless tables.empty?
        begin
          DataMapper.repository.adapter.execute("TRUNCATE TABLE #{tables.join(', ')} CASCADE")
        rescue DataObjects::SyntaxError => e
          # some table was never created
          $stderr.puts "Post-spec truncation failed: #{e}. This may not indicate a problem; just letting you know."
        end
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
