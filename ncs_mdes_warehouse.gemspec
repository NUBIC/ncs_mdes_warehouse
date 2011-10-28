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

  s.add_dependency 'ncs_mdes', '~> 0.4', '>= 0.4.2'
  s.add_dependency 'ncs_navigator_configuration', '~> 0.1'

  s.add_dependency 'activesupport', '~> 3.0'
  s.add_dependency 'i18n', '~> 0.6' # required by activesupport

  s.add_dependency 'thor', '~> 0.14.6'
  s.add_dependency 'rubyzip', '~> 0.9.4'

  s.add_dependency 'nokogiri', '~> 1.5.0'
  s.add_dependency 'builder', '~> 3.0'

  s.add_dependency 'data_mapper', '~> 1.2.0'
  s.add_dependency 'bcdatabase', '~> 1.1'
  s.add_dependency 'dm-postgres-adapter', '~> 1.2.0'

  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'yard', '~> 0.7.2'
  s.add_development_dependency 'ci_reporter', '~> 1.6.5'
  s.add_development_dependency 'fakefs', '~> 0.4.0'
end
