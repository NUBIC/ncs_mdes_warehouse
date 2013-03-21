NCS Navigator MDES Warehouse History
====================================

0.12.0
------

- Add models for MDES 3.2 based on 3.2.00.00. (#3631)

- Accept numeric strings with leading zeros for integer-typed properties.
  (#3491)

- Disable "humanizing" of variable names in validation messages. (#3486)

- Include MDES table name if available in TransformErrors. (#3487)

0.11.0
------

- Add `--and-pii` option to `emit-xml` to allow for simultaneously producing
  with- and without-PII XML from the same database reads. (#2285)

- Add `--directory` option to `emit-xml` to allow for writing files with the
  default names somewhere other than the current working directory. (#3073)

- Change `EnumTransformer` foreign key error handling. Foreign keys are
  now completely resolved in memory. Previously, foreign key errors were
  reported out of `EnumTransformer`, but the records were saved anyway. This
  was mostly in order to allow the database to handle circular reference
  resolution, but also because that implementation was simpler. The new
  implementation is expected to handle resolving all possible foreign key issues
  and so does not save records it finds to have bad FKs (or records that refer
  to those records, etc.) (#3188)

- In order to handle the previous, the interface for the object expected to be
  in the configuration property `foreign_key_index` has changed. In the very
  unlikely event that you were using a custom implementation, see the
  `Configuration#foreign_key_index` docs for the new protocol.

- Handle `xsi:nil` in `VdrXml::Reader`. (#3217)

- Limit caught exceptions in `EnumTransformer` to `StandardError` & subclasses.
  (#3243)

- Use `attribute_name` and `attribute_value` when creating TransformErrors for
  foreign key violations. (#3189)

- Report invalid properties or unresolvable FKs on records that have invalid
  PSU IDs. (#3264)

- Clean up shell output for `Database`-based enumerators. (Includes #3072.)

0.10.1
------

- Eliminate method name collisions when a generated model would have had
  both a property and a belongs_to with the same name. (#3184)

- Update MDES 3.1 models to 3.1.01.00. (#2750)

0.10.0
------

- Add MDES CSV transformer. (#2710)

- Enable use in Rails 3.2.7+ applications. ActiveSupport 3.2.4-3.2.6 had [an
  issue](https://github.com/rails/rails/pull/6857) which caused a conflict with
  DataMapper. This issue was fixed in 3.2.7.

0.9.0
-----

- Support symbolic references to models in `produce_one_for_one` in the database
  transformer DSL. This results in a minor *BREAKING CHANGE*:
  `Database::DSL::OneToOneProducer#model` has been renamed `model_or_name` and
  may give you either the model or a symbolic reference to it. There is a new
  method `#model(configuration)` which takes a configuration instance and always
  gives you a model. Similarly, `Database::DSL::OneToOneProducer#column_map` now
  requires a configuration instance as a second parameter. (#2552)

- Fix probably-never-functional `Configuration#mdes_version` reader. (#2553)

0.8.0
-----

- Provide metadata hash to row processors in `Database` transformer. The only
  provided metadata element at this point is reference to the active warehouse
  configuration. (#2451)

- Add models for MDES 3.1. (#2487)

0.7.3
-----

- Correct primary key resolution in FK index. (#2388)

- Remove autoload for MDES 2.0 models. MDES models should only be loaded via a
  warehouse configuration instance. Doing otherwise will likely confuse
  DataMapper.

0.7.2
-----

- Correct behavior of FK index with database external key provider. (#2387)

- Remove transaction handling in SqlTransformer. (Transformers are automatically
  wrapped in a transaction, so it's redundant for the transformer to do it
  itself.)

0.7.1
-----

- Defer acquisition of DM adapter in SqlTransformer until first use. (#2386)

0.7.0
-----

- Check foreign keys in memory during ETL. (#2013)

- Add duplicate detection and handling to EnumTransformer. (#2319)

- Add `SqlTransformer` for executing one or more SQL statements from a file.
  (#1861)

- Add models for MDES 3.0. (#2382)

0.6.2
-----

- Added `Configuration#model` to find a model class for a particular
  table name or unqualified class name in the current MDES version.

- Added transformer for automatically setting event start dates from
  the earliest associated contact (if any). (#2194)

0.6.1
-----

- Change validation error reporting: Each validation error in
  EnumTransformer now produces a separate TransformError. (Previously
  they were concatenated into a single error.) (#2155)

- Provide a SubprocessTransformer-compatible JSON serialization on
  TransformError. (#2199)

0.6.0
-----

- Add models for MDES 2.1 and 2.2. (#1973)

- Verify PSU IDs in EnumTransformer. (#2044)

- Resolve constants in configuration files against
  `NcsNavigator::Warehouse::Transformers` to reduce clutter.

- Add "filter" concept to EnumTransformer. (#2125)

- Extract cleanup behavior in VDR XML reader into two filters
  (CodedAsMissingFilter and NoBlankForeignKeysFilter). (#2125, #2144)

- Extract automatic `psu_id` and `recruit_type` setting from
  EnumTransformer into a filter (ApplyGlobalValuesFilter). (#2125)

- Add two filters for cleaning up outreach event records without
  associated SSUs. (#2130, #2131)

- Allow additional values to be specified for cleanup in
  CodedAsMissingFilter. (#2139)

- Add `count` subcommand to `mdes-wh`. (#2142)

0.5.0
-----

- Add "post-ETL hooks" to ETL process: objects with callbacks which
  are executed when the ETL completes. (#1725)

- Add post-ETL hook for sending e-mail when the ETL process completes,
  indicating success or failure. (#1601)

- Include the input filename in the name of transformers based on
  `VdrXml::Reader`. (#1927)

- Exclude parent bundler environment when executing subprocess in
  SubprocessTransformer. (#2012)

- Strip leading and trailing whitespace from values in one-to-one
  transformer. (#2028)

- Catch all exceptions during enumeration in EnumTransformer. (#2070)

- Log caught exceptions during ETL. Previously they were only reported
  to the shell and stored in the transform status table. (#2070)

- An enumerator may communicate recoverable errors to EnumTransformer
  by yielding one or more TransformErrors as part of its
  enumeration. (#2073)

0.4.1
-----

- Decode carriage returns that libxml2 refuses to decode. (#1940)

0.4.0
-----

- Restore creation of foreign key constraints during schema
  initialization. This was lost after upgrading to DataMapper 1.2 in
  the prehistory of the project. (#1639)

- Skip more unknown/missing codes when reading VDR XML. The reader now
  treats any non-coded, non-required field whose value is exactly -3,
  -4, -6, or -7 as NULL. (#1702)

- Skip entire records where the PK is one of the unknown/missing
  codes. (#1703)

- Prevent data integrity errors from killing the entire ETL
  process. They are now recorded as transform errors just like
  validation problems. (#1717)

- Ignore blank PII values when generating the `:pii` meta attribute
  for model properties. (Done with #1814)

- Create `no_pii` schema containing views with all PII excised. If
  there is a role named `mdes_warehouse_no_pii`, it will automatically
  be granted SELECT on the content of this schema. (#1814)

- Changed default emit-xml filename when PII is included. (#1816)

0.3.2
-----

- Correct VDR XML reader for the case of an MDES table that contains a
  variable with the same name as the table. (#1695)

- Include the Study Center record in the instances created from the
  `SamplingUnits` transformer. (#1690)

- Change the default compare level to 3. It turns out that the full
  compare is not that slow, so there's no reason to default it to 1.
  (#1691)

0.3.1
-----

- Ensure that {Configuration#configuration_file} is set before
  evaluating a configuration file so it can be used to configure
  transformers. (#1688)

0.3.0
-----

- Depend on the specific DataMapper modules we use, rather than the
  `data_mapper` meta-gem. Practically this only excludes
  dm-serializer, but dm-serializer monkeys with the CSV library in a
  way that interferes with other CSV-using libraries, so excluding it
  is necessary. (#1619, data_mapper/dm-serializer#25)

- Remove mdes-version command line option.

- Add `SubprocessTransformer` for executing external scripts to do
  ETL. (#1682)

0.2.0
-----

- Automatically set PSU ID and recruitment type in
  `Transformers::EnumTransformer` if they are not already set. (#1630,
  #1648)

- ETL: store invalid or failing record IDs as a separate column
  instead of as part of TransformError#message. (#1636)

- When an MDES model string variable is set from a BigDecimal, coerce
  it to a floating point string. The ruby default is scientific
  notation, but that's not permitted in the MDES.

- New options for `emit-xml`: `--tables`, `--zip`,
  `--include-pii`. (#1612, #1657, #1658)

- Add `compare` subcommand in `mdes-wh` for comparing the contents of
  two warehouses. (#1667)

0.1.1
-----

- Disable DataMapper's identity map during ETL. It caches created
  records in memory without limit, so it brings the system to a crawl
  when loading hundreds of thousands of records.

- Wrap each transformer in a transaction during ETL, and turn off
  synchronous commits. This combination (not tried separately) gives
  around a 10% speed boost.

- Loosen gem dependencies for compatibility with Rails 3.0.

- Add `Transformers::SamplingUnits` for generating PSU, SSU, and TSU
  records from the runtime configuration. (#1602)

- Changed default log path to `/var/log/nubic/ncs/warehouse`. This is
  parallel with the default configuration paths under `/etc`. (#1605)

- Improve error messages in `VdrXml.from_most_recent_file`. (#1604)

0.1.0
-----

- Implement actual ETL runner. It's accessible via the `etl`
  subcommand of the `mdes-wh` executable.

- Correct generated models so that association reference names and
  foreign key column names do not collide. This was previously
  possible when an MDES foreign key was not suffixed with "_id".

- Replace `model_row` helper in `Transformers::Database` with its own
  top-level production method, `produce_one_for_one`. The options and
  behavior are mostly the same as `model_row`, but this refactoring
  allows the results of the column mapping heuristic to be exposed to
  assist in writing DRYer importers.

0.0.2
-----

- Added `model_row` helper in Transformers::Database for
  heuristic-based semi-automatic mapping of transactional data to
  warehouse entries.

0.0.1
-----

- Initial version. Includes models for MDES 2.0 Patch and most
  peripheral functionality. Actual ETL still pending.
