NCS Navigator MDES Warehouse History
====================================

0.1.1
-----

- Disable DataMapper's identity map during ETL. It caches created
  records in memory without limit, so it brings the system to a crawl
  when loading hundreds of thousands of records.

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
