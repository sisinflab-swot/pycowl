from collections.abc import Collection as ABCCollection, Iterable, Iterator
from pathlib import Path
from typing import overload

from ._types import (
    AnnotationValue,
    Entity,
    LiteralValue,
    Primitive,
)

# Base types

class Object:
    def iri(self) -> IRI: ...
    def namespace(self) -> str: ...
    def remainder(self) -> str: ...
    def annotations(self) -> Collection[Annotation]: ...
    def is_reserved(self) -> bool: ...
    def has_primitive(self, primitive: Primitive) -> bool: ...
    def primitives(self) -> Collection[Primitive]: ...

class AnnotationProperty(Object):
    def __init__(self, iri: str | IRI) -> None: ...

class Annotation(Object):
    def __init__(
        self,
        prop: AnnotationProperty,
        value: AnnotationValue,
    ) -> None: ...
    def property(self) -> AnnotationProperty: ...
    def value(self) -> AnnotationValue: ...

class Collection[T: Object](Object, ABCCollection[T]):
    def __init__(self, items: Iterable[T]) -> None: ...

class Datatype(Object):
    INTEGER: Datatype
    DOUBLE: Datatype
    BOOLEAN: Datatype
    STRING: Datatype
    def __init__(self, iri: str | IRI) -> None: ...

class IRI(Object):
    def __init__(self, prefix: str, suffix: str | None = None) -> None: ...
    def as_string(self) -> str: ...

class Literal(Object):
    @overload
    def __init__(
        self,
        value: LiteralValue,
        datatype: Datatype | None = None,
    ) -> None: ...
    @overload
    def __init__(
        self,
        value: str,
        language: str,
    ) -> None: ...
    def datatype(self) -> Datatype: ...
    def value(self) -> str: ...
    def language(self) -> str | None: ...

# Class expressions

class ClassExpression(Object):
    def __and__(self, other: ClassExpression) -> ObjectIntersectionOf: ...
    def __or__(self, other: ClassExpression) -> ObjectUnionOf: ...
    def __invert__(self) -> ObjectComplementOf: ...
    def is_a(self, other: ClassExpression) -> SubClassOf: ...
    def that(self, *args: ClassExpression) -> ObjectIntersectionOf: ...

class Class(ClassExpression):
    def __init__(self, iri: str | IRI) -> None: ...

class NAryBooleanClassExpression(ClassExpression):
    def __init__(self, *args: ClassExpression) -> None: ...
    def operands(self) -> Collection[ClassExpression]: ...

class ObjectIntersectionOf(NAryBooleanClassExpression): ...
class ObjectUnionOf(NAryBooleanClassExpression): ...

class ObjectComplementOf(ClassExpression):
    def __init__(self, operand: ClassExpression) -> None: ...
    def operand(self) -> ClassExpression: ...

class ObjectQuantifiedRestriction(ClassExpression):
    def __init__(self, prop: ObjectPropertyExpression, filler: ClassExpression) -> None: ...
    def property(self) -> ObjectPropertyExpression: ...
    def filler(self) -> ClassExpression: ...

class ObjectSomeValuesFrom(ClassExpression): ...
class ObjectAllValuesFrom(ClassExpression): ...

class ObjectCardinalityRestriction(ClassExpression):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> None: ...
    def property(self) -> ObjectPropertyExpression: ...
    def cardinality(self) -> int: ...
    def filler(self) -> ClassExpression | None: ...

class ObjectMinCardinality(ObjectCardinalityRestriction): ...
class ObjectMaxCardinality(ObjectCardinalityRestriction): ...
class ObjectExactCardinality(ObjectCardinalityRestriction): ...

# Individuals

class Individual(Object):
    def is_a(self, cls: ClassExpression) -> ClassAssertion: ...

class NamedIndividual(Individual):
    def __init__(self, iri: str | IRI) -> None: ...

class AnonymousIndividual(Individual):
    def __init__(self, node_id: str | None = None) -> None: ...

# Object property expressions

class ObjectPropertyExpression(Object):
    def some(self, filler: ClassExpression) -> ObjectSomeValuesFrom: ...
    def all(self, filler: ClassExpression) -> ObjectAllValuesFrom: ...
    def min(
        self,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> ObjectMinCardinality: ...
    def max(
        self,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> ObjectMaxCardinality: ...
    def exactly(
        self,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> ObjectExactCardinality: ...
    def __call__(self, subj: Individual, obj: Individual) -> ObjectPropertyAssertion: ...

class ObjectProperty(ObjectPropertyExpression):
    def __init__(self, iri: str | IRI) -> None: ...

class InverseObjectProperty(ObjectPropertyExpression):
    def __init__(self, prop: ObjectProperty) -> None: ...
    def property(self) -> ObjectProperty: ...

# Data property expressions

class DataProperty(Object):
    def __init__(self, iri: str | IRI) -> None: ...
    def __call__(
        self,
        subj: Individual,
        value: Literal | LiteralValue,
    ) -> DataPropertyAssertion: ...

# Axioms

class Axiom(Object): ...

class Declaration(Axiom):
    def __init__(
        self,
        entity: Entity,
        annotations: Iterable[Annotation] | None = None,
    ) -> None: ...
    def entity(self) -> Entity: ...

class SubClassOf(Axiom):
    def __init__(
        self,
        sub_class: ClassExpression,
        super_class: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None: ...

class ClassAssertion(Axiom):
    def __init__(
        self,
        cls: ClassExpression,
        ind: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None: ...
    def class_expression(self) -> ClassExpression: ...
    def individual(self) -> Individual: ...

class ObjectPropertyAssertion(Axiom):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        subj: Individual,
        obj: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None: ...
    def __invert__(self) -> ObjectPropertyAssertion: ...
    def property(self) -> ObjectPropertyExpression: ...
    def subject(self) -> Individual: ...
    def object(self) -> Individual: ...

class NegativeObjectPropertyAssertion(ObjectPropertyAssertion): ...

class DataPropertyAssertion(Axiom):
    def __init__(
        self,
        prop: DataProperty,
        subj: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None: ...
    def __invert__(self) -> DataPropertyAssertion: ...
    def property(self) -> DataProperty: ...
    def subject(self) -> Individual: ...
    def value(self) -> Literal: ...

class NegativeDataPropertyAssertion(DataPropertyAssertion): ...

# Ontology

class Ontology(Object):
    @classmethod
    def at_path(cls, path: Path | str) -> Ontology: ...
    @property
    def prefix_map(self) -> PrefixMap: ...
    def __init__(self) -> None: ...
    def __contains__(self, item: Axiom | Primitive) -> bool: ...
    def axioms(self) -> Collection[Axiom]: ...
    def to_path(self, path: Path | str) -> None: ...
    def set_iri(self, iri: str | IRI, *, update_prefix: bool = False) -> None: ...
    def set_version(self, version: str | IRI) -> None: ...
    def add(self, *args: Annotation | Axiom | IRI) -> None: ...
    def remove(self, *args: Annotation | Axiom | IRI) -> None: ...

class PrefixMap(Object):
    @staticmethod
    def default() -> PrefixMap: ...
    def __init__(self) -> None: ...
    def __setitem__(self, prefix: str, ns: str) -> None: ...
    def __getitem__(self, prefix_or_ns: str) -> str: ...
    def __delitem__(self, prefix_or_ns: str) -> None: ...
    def __len__(self) -> int: ...
    def add(self, prefix: str, ns: str) -> None: ...
    def remove(self, prefix_or_ns: str) -> None: ...
    def get(self, prefix_or_ns: str) -> str | None: ...
    def items(self) -> Iterator[tuple[str, str]]: ...
    def prefixes(self) -> Iterator[str]: ...
    def namespaces(self) -> Iterator[str]: ...

# Vocabularies

class OWL:
    PREFIX: str
    NS: str

    BACKWARD_COMPATIBLE_WITH: IRI
    DEPRECATED: IRI
    INCOMPATIBLE_WITH: IRI
    PRIOR_VERSION: IRI
    VERSION_INFO: IRI

    BOTTOM_DATA_PROPERTY: DataProperty
    BOTTOM_OBJECT_PROPERTY: ObjectProperty
    NOTHING: Class
    RATIONAL: Datatype
    REAL: Datatype
    THING: Class
    TOP_DATA_PROPERTY: DataProperty
    TOP_OBJECT_PROPERTY: ObjectProperty

class RDF:
    PREFIX: str
    NS: str

    LANG_RANGE: IRI

    LANG_STRING: Datatype
    PLAIN_LITERAL: Datatype
    XML_LITERAL: Datatype

class RDFS:
    PREFIX: str
    NS: str

    COMMENT: IRI
    IS_DEFINED_BY: IRI
    LABEL: IRI
    SEE_ALSO: IRI

    LITERAL: Datatype

class XSD:
    PREFIX: str
    NS: str

    LENGTH: IRI
    MAX_EXCLUSIVE: IRI
    MAX_INCLUSIVE: IRI
    MAX_LENGTH: IRI
    MIN_EXCLUSIVE: IRI
    MIN_INCLUSIVE: IRI
    MIN_LENGTH: IRI
    PATTERN: IRI

    ANY_URI: Datatype
    BASE64_BINARY: Datatype
    BOOLEAN: Datatype
    BYTE: Datatype
    DATE_TIME: Datatype
    DATE_TIME_STAMP: Datatype
    DECIMAL: Datatype
    DOUBLE: Datatype
    FLOAT: Datatype
    HEX_BINARY: Datatype
    INT: Datatype
    INTEGER: Datatype
    LANGUAGE: Datatype
    LONG: Datatype
    NAME: Datatype
    NCNAME: Datatype
    NEGATIVE_INTEGER: Datatype
    NMTOKEN: Datatype
    NON_NEGATIVE_INTEGER: Datatype
    NON_POSITIVE_INTEGER: Datatype
    NORMALIZED_STRING: Datatype
    POSITIVE_INTEGER: Datatype
    SHORT: Datatype
    STRING: Datatype
    TOKEN: Datatype
    UNSIGNED_BYTE: Datatype
    UNSIGNED_INT: Datatype
    UNSIGNED_LONG: Datatype
    UNSIGNED_SHORT: Datatype
