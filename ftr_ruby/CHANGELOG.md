## [Unreleased]

## [0.1.11] - 2026-05-26

### Changed
- `TestInfra#get_tests_metrics` now fetches all test metrics in parallel using Ruby threads, significantly reducing latency when querying 40+ tests
- Refactored `TestInfra` internals into focused private helpers (`fetch_metric`, `fetch_metric_url`, `load_metric_graph`, `query_metric_graph`)
- `test_infrastructure.rb` now explicitly requires `jsonpath` rather than relying on transitive loading

### Added
- RSpec tests for `TestInfra#get_tests_metrics` and `#fetch_metric_url` covering happy path, missing metadata, RDF load failures, and empty input

## [0.1.0] - 2026-03-28

- Initial release
