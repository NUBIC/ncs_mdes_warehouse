# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ncs_navigator/warehouse/version"

Gem::Specification.new do |s|
  s.name        = "ncs_mdes_warehouse"
  s.version     = NcsNavigator::Warehouse::VERSION
  s.authors     = ["Rhett Sutphin"]
  s.email       = ["r-sutphin@northwestern.edu"]
  s.homepage    = ""
  s.summary     = %q{Scripts and models for building and maintaining the MDES-based reporting warehouse for NCS Navigator.}

  s.files         = `git ls-files`.split("\n") - ['irb']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "generated_models"]

  s.add_dependency 'ncs_mdes', '~> 0.10'
  s.add_dependency 'ncs_navigator_configuration', '~> 0.2'

  # AS 3.2.4-3.2.6 break DataMapper due to https://github.com/rails/rails/pull/6857
  # TODO: simplify this once we can drop support for AS 3.0 and 3.1
  s.add_dependency 'activesupport', '~> 3.0', '!= 3.2.4', '!= 3.2.5', '!= 3.2.6'
  s.add_dependency 'i18n', '~> 0.4' # required by activesupport

  s.add_dependency 'thor', '~> 0.14.6'
  s.add_dependency 'rubyzip', '~> 0.9.4'
  s.add_dependency 'childprocess', '~> 0.2.3'
  s.add_dependency 'json', '~> 1.6'

  s.add_dependency 'nokogiri', '~> 1.5.0'
  s.add_dependency 'builder', '>= 2.1.2'

  %w(
    dm-core dm-constraints dm-migrations dm-transactions dm-validations dm-types dm-aggregates
    dm-postgres-adapter
  ).each do |dm_gem|
    s.add_dependency dm_gem, '~> 1.2.0'
  end

  s.add_dependency 'bcdatabase', '~> 1.1'
  s.add_dependency 'actionmailer', '~> 3.0'

  s.add_dependency 'treetop'

  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'yard', '~> 0.7.2'
  s.add_development_dependency 'ci_reporter', '1.6.6'
  s.add_development_dependency 'fakefs', '0.4.0' # FakeFS does not follow semver
end
