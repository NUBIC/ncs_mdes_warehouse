require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

# require 'active_support/core_ext/string'
require 'ncs_navigator/mdes'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../generated_models', __FILE__)
require 'ncs_navigator/warehouse'

task :spec => 'spec:all'

namespace :spec do
  RSpec::Core::RakeTask.new(:fast) do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = %q(--format nested --tag ~slow)
  end

  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = %q(--format nested)
  end
end

namespace :generate do
  task :models do
    NcsNavigator::Warehouse::TableModeler.for_version(
      '2.0',
      :path => 'generated_models'
    ).model!
  end
end

namespace :ci do
  ENV["CI_REPORTS"] = "reports/spec-xml"

  task :all => :spec

  task :spec => ['ci:setup:rspec', 'rake:spec']
end
