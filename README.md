# NCS Navigator MDES Warehouse

MDES Warehouse is the central collation and reporting engine for the
NCS Navigator suite. It provides the infrastructure to support
transforming data from the operational and data-collection systems and
converting it into the format required for reporting to the National
Children's Study program office.

While it has been built for the NCS Navigator suite, it exposes
generic attachment points for transformers, potentially allowing it to
be used with other sets of transactional systems for the National
Children's Study.

## System Requirements

MDES Warehouse is installed as a ruby gem. It's compatible with Ruby
1.8.7 (including REE) and 1.9.2.  It relies on [PostgreSQL][pgsql] 9
(or later).

[pgsql]: http://www.postgresql.org/

## Set up

### Install the gem

    $ gem install ncs_mdes_warehouse

This will install the gem, all its dependencies, and the `mdes-wh`
executable.

### Set the environment

The warehouse detects the kind of environment it's running in
(production, staging, or development) via the `NCS_NAVIGATOR_ENV`
environment variable. Arrange for this variable to be set to an
appropriate value for the server where you're deploying the warehouse:

    # In, e.g., /etc/bashrc
    export NCS_NAVIGATOR_ENV=staging

If you're deploying on a workstation (i.e., for development) you can
skip this step -- the default environment is development.

### Configure the NCS Navigator suite

If you haven't already, create `/etc/nubic/ncs/navigator.ini` by
following the [example in the ncs_navigator_configuration
gem][confex].

[confex]: http://rubydoc.info/gems/ncs_navigator_configuration/file/sample_configuration.ini

### Create the PostgreSQL databases

The warehouse requires two PostgreSQL databases.  There are several
ways to create them. `createdb` is one:

    $ createuser -e -h dbserver.my.org -PRSD mdes_warehouse
    Enter password for new role:
    Enter it again:
    CREATE ROLE mdes_warehouse PASSWORD 'md5...' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;
    $ createdb -e -O mdes_warehouse mdes_warehouse_working
    CREATE DATABASE mdes_warehouse_working OWNER mdes_warehouse;
    $ createdb -e -O mdes_warehouse mdes_warehouse_reporting
    CREATE DATABASE mdes_warehouse_reporting OWNER mdes_warehouse;

### Configure bcdatabase

Like the rest of the NCS Navigator suite, MDES Warehouse uses
[bcdatabase][] to locate database access parameters and
credentials. Bcdatabase looks for credentials under
`/etc/nubic/db`. The specific file that the warehouse looks in will
depend on the environment in which you're running:

  * development: `local_postgresql.yml`
  * staging: `ncsdb_staging.yml`
  * production: `ncsdb_prod.yml`

Create or update the appropriate file with the warehouse configuration
for your environment. The below is an example; yours may differ. The
MDES Warehouse-specifc parts are the `datamapper_adapter`
configuration key and the two `mdes_warehouse_*` entries.

    defaults:
      host: ncsdb-staging.my.org
      adapter: postgresql
      datamapper_adapter: postgres
    mdes_warehouse_working:
      username: mdes_warehouse
      password: whatever-i-entered-before
    mdes_warehouse_reporting:
      username: mdes_warehouse
      password: whatever-i-entered-before

[bcdatabase]: http://rubydoc.info/gems/bcdatabase/frames

### Configure warehouse

The warehouse takes its base configuration from a file under the
directory `/etc/nubic/ncs/warehouse`. The name of the file should be
`${NCS_NAVIGATOR_ENV}.rb`; e.g., for the production environment, the
full path would be `/etc/nubic/ncs/warehouse/production.rb`.

The minimum contents of this file is a list of transformers, which are
components that translate data from some source system or systems:

    transformer VdrXml.from_most_recent_file(Dir['/var/lib/ncs/mdes/COOK*.xml'])
    transformer StaffPortal.create_transformer

The warehouse includes some transformers. Others are included with the
NCS Navigator suite applications themselves. See below for more
information (TODO).

The warehouse configuration file may optionally include other
overrides to MDES warehouse defaults. See the documentation for
{NcsNavigator::Warehouse::Configuration::DSL} for details.

### Verify your settings

You can verify most of these settings by running this command:

    $ mdes-wh create-schema

It will connect to the working database and create a schema matching
the current MDES version.

TODO: a more complete verification utility.

## Use

MDES Warehouse provides an executable named `mdes-wh` which has
several subcommands. To get a list of the commands, use `mdes-wh
help`.
