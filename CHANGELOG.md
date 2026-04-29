# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Added

- `ClassExpression.is_same_as` as an alias for `ClassExpression.is_equivalent_to`.
- `DataRange.that` fluent API.

### Fixed

- Implemented `__and__` and `__or__` for `DataRange`.
- Improved type annotations for generic methods.


## [0.1.0] - 2026-04-13

### Added

- Full OWL 2 data model.
- Ability to edit ontologies.
- Ability to query ontologies.
- Read and write support for the OWL 2 Functional syntax.


[unreleased]: https://github.com/sisinflab-swot/pycowl/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/sisinflab-swot/pycowl/compare/base...v0.1.0
