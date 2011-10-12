require 'ncs_navigator/warehouse'

class NcsNavigator::Warehouse::Configuration
  ##
  # Defines the language that is used in MDES Warehouse configuration
  # files and in the block form of the {Configuration} constructor.
  #
  # Example with all configuration elements:
  #
  #     # Define the transformers used in this configuration. The
  #     # transformers will be used in the order they are defined.
  #     transformer Foo.new
  #     transformer Bar.new
  #
  #     # The MDES version to use in this instance of the warehouse.
  #     # The default depends on the version of the warehouse you're
  #     # using.
  #     mdes_version '2.0'
  #
  #     # Select a bcdatabase group to use to locate database access
  #     # information and credentials. The default is defined by the
  #     # environment.
  #     bcdatabase_group :custom
  #
  #     # Select the bcdatabase entries to use to locate database
  #     # information and credentials. MDES Warehouse uses two
  #     # databases. This entry shows the default values. You can
  #     # you can also override only one or the other.
  #     bcdatabase_entries :working => :mdes_warehouse_working,
  #                        :reporting => :mdes_warehouse_reporting
  #
  #     # The path to the basic configuration of the suite.
  #     # The default is '/etc/nubic/ncs/navigator.ini'. It's unlikely
  #     # that you will need to change this unless you are accessing
  #     # warehouses for multiple centers from the same machine.
  #     navigator_ini '/etc/nubic/ncs/navigator.ini'
  #
  #     # The logger to use in the warehouse. If none is specified,
  #     # logging will go to standard out. TODO: may be ruby logger or
  #     # filename or directory (?). Need to figure out rotation.
  #     log '/var/log/ncs/warehouse.log'
  #
  #     # Control the terminal output when running interactively.
  #     # Options are :normal or :quiet. The default is :normal; it
  #     # will usually make more sense to control this from the
  #     # command line.
  #     output_level :normal
  module DSL
  end
end
