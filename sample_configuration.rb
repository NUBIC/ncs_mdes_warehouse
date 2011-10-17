# @markup ruby
# @title sample_configuration.rb

# Sample environment configuration script for NCS Navigator MDES
# Warehouse.  See the README for information on where to put this file
# and what to call it. In general, you will only need to define
# transformers.

# When the configuration file is evaluated, the configuration that is
# being created/updated is available under the name `configuration` or
# the alias `c`. For more information about the configuration methods
# that you can invoke in this file, see the API documentation for
# {NcsNavigator::Warehouse::Configuration}.

# Define the transformers used in this configuration. The
# transformers will be used in the order they are defined.
c.add_transformer Foo.new
c.add_transformer Bar.new(configuration)

# The MDES version to use in this instance of the warehouse.
# The default depends on the version of the warehouse you're
# using.
#c.mdes_version = '2.0'

# Select a bcdatabase group to use to locate database access
# information and credentials. The default is defined by the
# environment.
#c.bcdatabase_group = :some_other_group

# Select the bcdatabase entries to use to locate database
# information and credentials. MDES Warehouse uses two
# databases.
#c.bcdatabase_entries[:working] = :mdes_warehouse_working
#c.bcdatabase_entries[:reporting] = :mdes_warehouse_reporting

# The path to the basic configuration of the suite.
# The default is '/etc/nubic/ncs/navigator.ini'. It's unlikely
# that you will need to change this unless you are accessing
# warehouses for multiple centers from the same machine.
#c.navigator_ini = '/etc/nubic/ncs/navigator.ini'

# The logger to use in the warehouse. If none is specified,
# logging will go to standard out. TODO: may be ruby logger or
# filename or directory (?). Need to figure out rotation.
#c.log_file = '/var/log/ncs/warehouse.log'

# Control the terminal output when running interactively.
# Options are :normal or :quiet. The default is :normal; it
# will usually make more sense to control this from the
# command line.
c.output_level = :normal
