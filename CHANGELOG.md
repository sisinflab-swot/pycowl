# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Added
- `Reader` and related APIs.
- Ability to read OWL documents as streams of constructs (`Reader.stream`).
- ProtocOWL reader and writer (`Reader.protocowl`, `Writer.protocowl`).
- CLI tools: `convert`, `diff`, `stats`.
- `Change` and related APIs.
- `Writer.name`, `Writer.set_default`.
- `PrefixMap.declarations_iter`.

### Changed
- Support multiple axiom types in `Ontology.related` and `Ontology.foreach_related`.


## [0.1.1] - 2026-05-11

### Added
- `Writer` and related APIs.
- `ClassExpression.is_same_as` as an alias for `ClassExpression.is_equivalent_to`.
- `DataRange.that` fluent API.
- `intersection_of` and `union_of` utility functions.
- `Ontology.axiom_count`, `Ontology.primitive_count`, and `Ontology.imports`.
- Type guard functions (`is_entity`, `is_primitive`, `is_axiom`, etc.).

### Changed
- Replaced `Ontology` methods `at_path` and `to_path` with `read` and `write`.

### Fixed
- Implemented `__and__` and `__or__` for `DataRange`.
- `bool` values interpreted as `xsd:integer` literals.
- Equality method accepting only Self for `Datatype` and `DatatypeRestriction`.
- Improved type annotations for generic methods.


## [0.1.0] - 2026-04-13

### Added
- Full OWL 2 data model.
- Ability to edit ontologies.
- Ability to query ontologies.
- Read and write support for the OWL 2 Functional syntax.


[unreleased]: https://github.com/sisinflab-swot/pycowl/compare/stable...HEAD
[0.1.1]: https://github.com/sisinflab-swot/pycowl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/sisinflab-swot/pycowl/compare/base...v0.1.0
