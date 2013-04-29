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

# Define the transformers used in this configuration. The transformers
# will be used in the order they are defined.
c.add_transformer Foo.new
c.add_transformer Bar.new(configuration)

# The MDES version to use in this instance of the warehouse.  The
# default depends on the version of the warehouse you're using.
#c.mdes_version = '2.0'

# Select a bcdatabase group to use to locate database access
# information and credentials. The default is defined by the
# environment.
#c.bcdatabase_group = :some_other_group

# Select the bcdatabase entries to use to locate database information
# and credentials. MDES Warehouse uses two databases.
#c.bcdatabase_entries[:working] = :mdes_warehouse_working
#c.bcdatabase_entries[:reporting] = :mdes_warehouse_reporting

# The path to the basic configuration of the suite.  The default is
# '/etc/nubic/ncs/navigator.ini'. It's unlikely that you will need to
# change this unless you are accessing warehouses for multiple centers
# from the same machine.
#c.navigator_ini = '/etc/nubic/ncs/navigator.ini'

# The file to which to log the warehouse's actions. Defaults to
# '/var/log/ncs/warehouse/{env_name}.log'. See the README for more
# information about logs.
#c.log_file = '/var/log/ncs/warehouse/something_else.log'

# Control the terminal output when running interactively.  Options are
# :normal or :quiet. The default is :normal; it will usually make more
# sense to control this from the command line.
#c.output_level = :normal

# Give a set of one or more filters a name.
# This name can be used with `emit-xml` to apply the filter during export.
c.add_filter_set :quux, [FilterOne, lambda { |recs| recs }, FilterThree.new(c)]

# Filter sets may include other filter sets:
c.add_filter_set :baz, [FilterSeven.new, :quux]

# Specify a filter set to use by default in emit-xml. Any filter referenced
# using --filters in the invocation of emit-xml will be used _instead_ of this
# filter.
c.default_xml_filter_set = :quux
