NCS Navigator MDES Warehouse History
====================================

0.0.3
-----

- Correct generated models so that association reference names and
  foreign key column names do not collide. This was previously
  possible when an MDES foreign key was not suffixed with "_id".

0.0.2
-----

- Added `model_row` helper in Transformers::Database for
  heuristic-based semi-automatic mapping of transactional data to
  warehouse entries.

0.0.1
-----

- Initial version. Includes models for MDES 2.0 Patch and most
  peripheral functionality. Actual ETL still pending.
