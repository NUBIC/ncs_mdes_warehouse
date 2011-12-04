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
    t.rspec_opts = %q(--tag ~slow)
  end

  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = "spec/**/*_spec.rb"
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
  task :all => :spec

  task :spec_setup do
    ENV['CI_REPORTS'] = 'reports/spec-xml'
    ENV['SPEC_OPTS'] = "#{ENV['SPEC_OPTS']} --format nested --no-color"
  end

  task :spec => [:spec_setup, 'ci:setup:rspecbase', 'rake:spec']
end
