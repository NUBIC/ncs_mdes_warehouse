NCS Navigator MDES Warehouse History
====================================

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

- Create `no_pii` schema containing views with all PII
  excised. (#1814)

- Create `mdes_warehouse_no_pii` role that has read-only access to the
  contents of the `no_pii` schema. (#1814)

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
