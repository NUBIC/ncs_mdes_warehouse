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

init = DatabaseInitializer.new(:local_postgresql)

$stderr.puts "Loading MDES models"
$stderr.puts Benchmark.measure('load time') { require 'ncs_navigator/warehouse/models/two_point_zero' }

init.init_schema!

# fn = '/Volumes/VDR Data/constructed/20110720_cook_listings_out.xml'
fn = '/Volumes/VDR Data/NORC Submissions/COOK27JUL11.xml'
l = MdesLoader.new(fn).load!

puts "\r%d seconds total -- %3.1f records/sec#{' ' * 30}" % [l.load_time, l.load_rate]
puts "Breakdown:"
(l.good + l.bad).inject(ActiveSupport::OrderedHash.new) { |h, i| k = i.class.mdes_table_name; h[k] ||= 0; h[k] += 1; h }.
  each { |k, ct| puts "%6d #{k}" % ct }
puts "%6d valid instances encountered" % l.good.size
puts "%6d bad instances encountered" % l.bad.size
