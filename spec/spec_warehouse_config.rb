require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  module Spec
    # Each test run can only operate against one version of the MDES at
    # a time. The CI build is set up to run serially with this
    # environment variable set with each supported version.
    def self.mdes_version
      @mdes_version ||=
        (ENV['SPEC_MDES_VERSION'] || NcsNavigator::Warehouse::DEFAULT_MDES_VERSION).
        gsub(/[^\d\.]/, '')
    end

    def self.configuration
      @configuration ||= NcsNavigator::Warehouse::Configuration.new.tap do |c|
        c.mdes_version = self.mdes_version
        # This is used for rake invocations only; within specs the log
        # goes to the spec tmpdir for cleanup.
        c.log_file = File.expand_path('../spec.log', __FILE__)
        c.bcdatabase_group = ENV['CI_RUBY'] ? :public_ci_postgresql9 : :local_postgresql
        c.bcdatabase_entries[:working] = :mdes_warehouse_working_test
        c.bcdatabase_entries[:reporting] = :mdes_warehouse_reporting_test
      end
    end

    def self.database_initializer
      @database_initializer ||= DatabaseInitializer.new(configuration)
    end
  end
end
