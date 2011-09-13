require 'rspec'

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'ncs_navigator/warehouse'
require 'ncs_navigator/configuration'

$LOAD_PATH.push File.expand_path('..', __FILE__)

require 'global_state_helper'

require 'data_mapper'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:all) do
    NcsNavigator::Warehouse.bcdatabase =
      Bcdatabase.load(File.expand_path('../bcdatabase', __FILE__), :transforms => [:datamapper])
  end

  config.before(:each, :modifies_warehouse_state) do
    @global_state_preserver = NcsNavigator::Warehouse::Spec::GlobalStatePreserver.new.save
  end

  def clear_warehouse_state
    @global_state_preserver.clear
  end

  config.after(:each, :modifies_warehouse_state) do
    @global_state_preserver.restore
  end

  config.after do
    FileUtils.rm_rf @tmpdir if @tmpdir && !ENV['KEEP_TMP']
  end

  def tmpdir(*path)
    @tmpdir ||= File.expand_path('../../tmp', __FILE__).
      tap { |p| FileUtils.mkdir_p p }
    if path.empty?
      @tmpdir
    else
      File.join(@tmpdir, *path).tap { |p| FileUtils.mkdir_p p }
    end
  end
end

NcsNavigator.configuration =
  NcsNavigator::Configuration.new(File.expand_path('../navigator.ini', __FILE__))
