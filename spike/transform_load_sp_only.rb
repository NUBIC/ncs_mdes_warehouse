#!/usr/bin/env ruby

require 'bundler'
Bundler.setup

$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../generated_models', __FILE__)

require 'ncs_navigator/warehouse'

require 'pp'
require 'active_support/ordered_hash'
require 'benchmark'

require File.expand_path('../mdes_loader.rb', __FILE__)
require File.expand_path('../db_initializer.rb', __FILE__)

init = DatabaseInitializer.new

$stderr.puts "Loading MDES models"
$stderr.puts Benchmark.measure('load time') { require 'ncs_navigator/warehouse/models/two_point_zero' }

init.init_schema!

require File.expand_path('../staff_portal_transformer.rb', __FILE__)
$stderr.puts Benchmark.measure('transform time') {
  StaffPortalTransformer.new.transform
}
