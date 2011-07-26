require 'rspec/core/rake_task'
require 'active_support/core_ext/string'
require 'ncs_navigator/mdes'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ncs_navigator/warehouse'

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

namespace :generate do
  task :models do
    NcsNavigator::Warehouse::TableModeler.for_version(
      '2.0',
      :path => 'generated_models'
    ).model!
  end
end
