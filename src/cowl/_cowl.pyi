from collections.abc import (
    Callable,
    Collection as ABCCollection,
    Iterable,
    MutableMapping,
)
from datetime import date, datetime
from enum import IntFlag, auto
from pathlib import Path
from typing import NoReturn, Protocol, overload

# Utilities

@overload
def one_of(*args: Individual) -> ObjectOneOf:
    """Create an enumeration of individuals."""

@overload
def one_of(*args: Literal | LiteralValue) -> DataOneOf:
    """Create an enumeration of literals."""

@overload
def all_equivalent(*args: ClassExpression) -> EquivalentClasses:
    """Create an equivalent classes axiom."""

@overload
def all_equivalent(*args: ObjectPropertyExpression) -> EquivalentObjectProperties:
    """Create an equivalent object properties axiom."""

@overload
def all_equivalent(*args: DataProperty) -> EquivalentDataProperties:
    """Create an equivalent data properties axiom."""

@overload
def all_disjoint(*args: ClassExpression) -> DisjointClasses:
    """Create a disjoint classes axiom."""

@overload
def all_disjoint(*args: ObjectPropertyExpression) -> DisjointObjectProperties:
    """Create a disjoint object properties axiom."""

@overload
def all_disjoint(*args: DataProperty) -> DisjointDataProperties:
    """Create a disjoint data properties axiom."""

def all_same(*args: Individual) -> SameIndividual:
    """Create an individual equality axiom."""

def all_different(*args: Individual) -> DifferentIndividuals:
    """Create an individual inequality axiom."""

def chain(*args: ObjectPropertyExpression) -> ObjectPropertyChain:
    """Create an object property chain."""

# Protocols

class Annotated(Protocol):
    """Protocol for objects that can have annotations."""

    def annotations(self) -> Collection[Annotation]:
        """Return the annotations of this object."""

class HasIRI(Protocol):
    """Protocol for objects that have an IRI."""

    def iri(self) -> IRI:
        """Return the IRI."""

    def namespace(self) -> str:
        """Return the namespace."""

    def remainder(self) -> str:
        """Return the remainder."""

class HasObjectProperty(Protocol):
    """Protocol for objects that have an object property."""

    def property_(self) -> ObjectPropertyExpression:
        """Return the object property expression."""

class HasDataProperty(Protocol):
    """Protocol for objects that have a data property."""

    def property_(self) -> DataProperty:
        """Return the data property."""

class HasAnnotationProperty(Protocol):
    """Protocol for objects that have an annotation property."""

    def property_(self) -> AnnotationProperty:
        """Return the annotation property."""

class HasPrimitives(Protocol):
    """Protocol for objects that can reference primitives."""

    def has_primitive(self, primitive: Primitive) -> bool:
        """Return whether this object references the primitive."""

    def foreach_primitive(self, func: Callable[[Primitive], None]) -> None:
        """Apply a function to each referenced primitive."""

    def primitives(self) -> Collection[Primitive]:
        """Return the referenced primitives."""

class PrimitiveFactory(Protocol):
    """
    Protocol for objects that can create primitives given short or full IRIs.

    Specifically, the provided strings can be either full IRIs or prefixed names.
    Prefixed names are expanded according to the prefix mappings of the object.

    For convenience, it is also possible to pass a suffix string without any prefix,
    in which case the default prefix will be used for expansion.
    """

    # ruff: disable[N802]
    def IRI(self, iri: str) -> IRI:
        """Create an IRI."""

    def Class(self, iri: str | IRI) -> Class:
        """Create a class."""

    def Datatype(self, iri: str | IRI) -> Datatype:
        """Create a datatype."""

    def ObjectProperty(self, iri: str | IRI) -> ObjectProperty:
        """Create an object property."""

    def DataProperty(self, iri: str | IRI) -> DataProperty:
        """Create a data property."""

    def AnnotationProperty(self, iri: str | IRI) -> AnnotationProperty:
        """Create an annotation property."""

    def NamedIndividual(self, iri: str | IRI) -> NamedIndividual:
        """Create a named individual."""

    def AnonymousIndividual(self, node_id: str | None = None) -> AnonymousIndividual:
        """Create an anonymous individual."""

    @overload
    def Individual(self, iri: str | IRI) -> NamedIndividual:
        """Create a named individual."""

    @overload
    def Individual(self) -> AnonymousIndividual:
        """Create an anonymous individual."""

    # ruff: enable[N802]

# Enums

class Position(IntFlag):
    """Positions within an axiom."""

    LEFT = auto()
    RIGHT = auto()
    MIDDLE = auto()

    ANY = LEFT | RIGHT | MIDDLE  # noqa: PYI026
    SUBJECT = LEFT
    PREDICATE = MIDDLE
    OBJECT = RIGHT
    VALUE = RIGHT

# Base types

class Object:
    """Base OWL object."""

    def __init__(self) -> NoReturn:
        """Create an OWL object."""

    def is_entity(self) -> bool:
        """Return whether this object is an entity."""

    def is_primitive(self) -> bool:
        """Return whether this object is primitive."""

    def is_axiom(self) -> bool:
        """Return whether this object is an axiom."""

    def is_class_expression(self) -> bool:
        """Return whether this object is a class expression."""

    def is_data_range(self) -> bool:
        """Return whether this object is a data range."""

    def is_object_property_expression(self) -> bool:
        """Return whether this object is an object property expression."""

    def is_data_property_expression(self) -> bool:
        """Return whether this object is a data property expression."""

    def is_individual(self) -> bool:
        """Return whether this object is an individual."""

class Primitive(Object, HasPrimitives):
    """
    Primitive term.

    "Primitive" is a collective term for entities, IRIs, and anonymous individuals.
    """

    def is_reserved(self) -> bool:
        """Return whether this primitive is part of the reserved vocabulary."""

class Entity(Primitive, HasIRI):
    """Named entity."""

    def declare(self) -> Declaration:
        """Create a declaration axiom for this entity."""

class AnnotationProperty(Entity):
    """Annotation property."""

    def __init__(self, iri: str | IRI) -> None:
        """Create an annotation property."""

    @overload
    def __call__(self, value: AnnotationValue | LiteralValue, /) -> Annotation:
        """Create an annotation with this property and the given value."""

    @overload
    def __call__(
        self,
        subject: AnnotationSubject | HasIRI,
        value: AnnotationValue | LiteralValue,
        /,
    ) -> AnnotationAssertion:
        """Create an annotation assertion."""

    def is_subproperty_of(self, parent: AnnotationProperty) -> SubAnnotationPropertyOf:
        """Create a sub-annotation property axiom."""

    def has_domain(self, domain: IRI) -> AnnotationPropertyDomain:
        """Create an annotation property domain axiom."""

    def has_range(self, range_: IRI) -> AnnotationPropertyRange:
        """Create an annotation property range axiom."""

type AnnotationSubject = IRI | AnonymousIndividual
"""The subject of annotations can be an IRI or an anonymous individual."""

type AnnotationValue = IRI | Literal | AnonymousIndividual
"""The value of annotations can be an IRI, a literal, or an anonymous individual."""

class Annotation(Object, Annotated, HasPrimitives, HasAnnotationProperty):
    """Annotation."""

    def __init__(
        self,
        property_: AnnotationProperty,
        value: AnnotationValue,
    ) -> None:
        """Create an annotation."""

    def value(self) -> AnnotationValue:
        """Return the annotation value."""

class Collection[T: Object](Object, HasPrimitives, ABCCollection[T]):
    """Collection of OWL objects."""

    def __init__(self, *args: T) -> None:
        """Create a collection."""

class IRI(Primitive, HasIRI):
    """IRI."""

    def __init__(self, prefix: str, suffix: str | None = None) -> None:
        """Create an IRI."""

    def __call__(self, value: Literal | LiteralValue) -> FacetRestriction:
        """Create a facet restriction with this IRI as the facet."""

    def as_string(self) -> str:
        """Return the string form of the IRI with no angle brackets."""

"""Literal value."""
type LiteralValue = str | int | float | bool | date | datetime

class Literal(Object, HasPrimitives):
    """Literal."""

    @overload
    def __init__(
        self,
        value: LiteralValue,
        datatype: Datatype | None = None,
    ) -> None:
        """
        Create a literal with an optional datatype.

        If the datatype is not provided, it will be inferred from the value type.
        """

    @overload
    def __init__(
        self,
        value: str,
        language: str | None = None,
    ) -> None:
        """Create a string literal, optionally with a language tag."""

    def datatype(self) -> Datatype:
        """Return the literal datatype."""

    def value(self) -> str:
        """Return the lexical form."""

    def language(self) -> str | None:
        """Return the language tag, if any."""

# Class expressions

class ClassExpression(Object, HasPrimitives):
    """Class expression."""

    @overload
    def __call__(self, individual: Individual) -> ClassAssertion:
        """Create a class assertion."""

    @overload
    def __call__(self, parent: ClassExpression) -> SubClassOf:
        """Create a subclass axiom."""

    def __and__(self, other: ClassExpression) -> ObjectIntersectionOf:
        """Create an intersection class expression."""

    def __or__(self, other: ClassExpression) -> ObjectUnionOf:
        """Create a union class expression."""

    def __invert__(self: ClassExpression) -> ClassExpression:
        """Create a complement class expression."""

    def that(self, *args: ClassExpression) -> ObjectIntersectionOf:
        """Create an intersection class expression."""

    def is_a(self, parent: ClassExpression) -> SubClassOf:
        """Create a subclass axiom."""

    def is_not_a(self, other: ClassExpression) -> DisjointClasses:
        """Create a disjoint classes axiom."""

    def is_subclass_of(self, parent: ClassExpression) -> SubClassOf:
        """Create a subclass axiom."""

    def is_equivalent_to(self, *args: ClassExpression) -> EquivalentClasses:
        """Create an equivalent classes axiom."""

    def is_disjoint_with(self, *args: ClassExpression) -> DisjointClasses:
        """Create a disjoint classes axiom."""

    def has_key(self, *args: ObjectPropertyExpression | DataProperty) -> HasKey:
        """Create a key axiom."""

class Class(ClassExpression, Entity):
    """Class."""

    def __init__(self, iri: str | IRI) -> None:
        """Create a class."""

    def is_disjoint_union_of(self, *args: ClassExpression) -> DisjointUnion:
        """Create a disjoint union axiom."""

class NAryClassExpression(ClassExpression):
    """N-ary class expression."""

    def operands(self) -> Collection[ClassExpression]:
        """Return the operands."""

class ObjectIntersectionOf(NAryClassExpression):
    """Intersection class expression."""

    def __init__(self, *args: ClassExpression) -> None:
        """Create an intersection class expression."""

class ObjectUnionOf(NAryClassExpression):
    """Union class expression."""

    def __init__(self, *args: ClassExpression) -> None:
        """Create a union class expression."""

class ObjectComplementOf(ClassExpression):
    """Complement class expression."""

    def __init__(self, operand: ClassExpression) -> None:
        """Create a complement class expression."""

    def operand(self) -> ClassExpression:
        """Return the operand."""

class ObjectOneOf(ClassExpression):
    """Enumeration of individuals."""

    def __init__(self, *args: Individual) -> None:
        """Create an enumeration of individuals."""

    def individuals(self) -> Collection[Individual]:
        """Return the individuals."""

class ObjectQuantifiedRestriction(ClassExpression, HasObjectProperty):
    """Object property restriction."""

    def filler(self) -> ClassExpression:
        """Return the filler class expression."""

class ObjectSomeValuesFrom(ObjectQuantifiedRestriction):
    """Existential object property restriction."""

    def __init__(self, property_: ObjectPropertyExpression, filler: ClassExpression) -> None:
        """Create an existential object property restriction."""

class ObjectAllValuesFrom(ObjectQuantifiedRestriction):
    """Universal object property restriction."""

    def __init__(self, property_: ObjectPropertyExpression, filler: ClassExpression) -> None:
        """Create a universal object property restriction."""

class ObjectHasSelf(ClassExpression, HasObjectProperty):
    """Self-restriction."""

    def __init__(self, property_: ObjectPropertyExpression) -> None:
        """Create a self-restriction."""

class ObjectHasValue(ClassExpression, HasObjectProperty):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        value: Individual,
    ) -> None:
        """Create a has-value class expression."""

    def value(self) -> Individual:
        """Return the individual."""

class ObjectCardinalityRestriction(ClassExpression, HasObjectProperty):
    """Object property cardinality restriction."""

    def cardinality(self) -> int:
        """Return the cardinality."""

    def filler(self) -> ClassExpression | None:
        """Return the optional filler class expression."""

class ObjectMinCardinality(ObjectCardinalityRestriction):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> None:
        """Create a minimum object property cardinality restriction."""

class ObjectMaxCardinality(ObjectCardinalityRestriction):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> None:
        """Create a maximum object property cardinality restriction."""

class ObjectExactCardinality(ObjectCardinalityRestriction):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> None:
        """Create an exact object property cardinality restriction."""

class DataQuantifiedRestriction(ClassExpression, HasDataProperty):
    """Data property restriction."""

    def range(self) -> DataRange:
        """Return the data range."""

class DataSomeValuesFrom(DataQuantifiedRestriction):
    """Existential data property restriction."""

    def __init__(self, property_: DataProperty, data_range: DataRange) -> None:
        """Create an existential data property restriction."""

class DataAllValuesFrom(DataQuantifiedRestriction):
    """Universal data property restriction."""

    def __init__(self, property_: DataProperty, data_range: DataRange) -> None:
        """Create a universal data property restriction."""

class DataHasValue(ClassExpression, HasDataProperty):
    def __init__(
        self,
        property_: DataProperty,
        value: Literal,
    ) -> None:
        """Create a has-value data property restriction."""

    def value(self) -> Literal:
        """Return the literal."""

class DataCardinalityRestriction(ClassExpression, HasDataProperty):
    """Data property cardinality restriction."""

    def cardinality(self) -> int:
        """Return the cardinality."""

    def range(self) -> DataRange | None:
        """Return the optional data range."""

class DataMinCardinality(DataCardinalityRestriction):
    def __init__(
        self,
        property_: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None,
    ) -> None:
        """Create a minimum data property cardinality restriction."""

class DataMaxCardinality(DataCardinalityRestriction):
    def __init__(
        self,
        property_: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None,
    ) -> None:
        """Create a maximum data property cardinality restriction."""

class DataExactCardinality(DataCardinalityRestriction):
    def __init__(
        self,
        property_: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None,
    ) -> None:
        """Create an exact data property cardinality restriction."""

# Data ranges

class DataRange(Object, HasPrimitives):
    """Data range."""

    def __and__(self, other: DataRange) -> DataIntersectionOf:
        """Create an intersection data range."""

    def __or__(self, other: DataRange) -> DataUnionOf:
        """Create a union data range."""

    def __invert__(self: DataRange) -> DataRange:
        """Create a complement data range."""

class Datatype(DataRange, Entity):
    """Datatype."""

    def __init__(self, iri: str | IRI) -> None:
        """Create a datatype."""

    def __call__(self, value: LiteralValue) -> Literal:
        """Create a literal of this datatype."""

    def __getitem__(self, item: FacetRestriction) -> DatatypeRestriction:
        """Create a datatype restriction."""

    def __le__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an inclusive maximum datatype restriction."""

    def __lt__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an exclusive maximum datatype restriction."""

    def __ge__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an inclusive minimum datatype restriction."""

    def __gt__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an exclusive minimum datatype restriction."""

    def is_defined_as(self, data_range: DataRange) -> DatatypeDefinition:
        """Create a datatype definition."""

    def that_has(
        self,
        *args: FacetRestriction,
        length: Literal | int | None = None,
        min_length: Literal | int | None = None,
        max_length: Literal | int | None = None,
        value_gt: Literal | LiteralValue | None = None,
        value_ge: Literal | LiteralValue | None = None,
        value_lt: Literal | LiteralValue | None = None,
        value_le: Literal | LiteralValue | None = None,
        pattern: Literal | str | None = None,
        lang_range: Literal | str | None = None,
    ) -> DatatypeRestriction:
        """Create a datatype restriction."""

class NAryDataRange(DataRange):
    """N-ary data range."""

    def operands(self) -> Collection[DataRange]:
        """Return the operands."""

class DataIntersectionOf(NAryDataRange):
    """Intersection data range."""

    def __init__(self, *args: DataRange) -> None:
        """Create an intersection data range."""

class DataUnionOf(NAryDataRange):
    """Union data range."""

    def __init__(self, *args: DataRange) -> None:
        """Create a union data range."""

class DataComplementOf(DataRange):
    """Complement data range."""

    def __init__(self, operand: DataRange) -> None:
        """Create a complement data range."""

    def operand(self) -> DataRange:
        """Return the operand."""

class DataOneOf(DataRange):
    """Enumeration of literals."""

    def __init__(self, *args: Literal) -> None:
        """Create an enumeration of literals."""

    def values(self) -> Collection[Literal]:
        """Return the literals."""

class FacetRestriction(Object):
    """Facet restriction."""

    def __init__(
        self,
        facet: IRI,
        value: Literal,
    ) -> None:
        """Create a facet restriction."""

    def facet(self) -> IRI:
        """Return the facet IRI."""

    def value(self) -> Literal:
        """Return the restriction value."""

class DatatypeRestriction(DataRange):
    """Datatype restriction."""

    def __init__(
        self,
        datatype: Datatype,
        *args: FacetRestriction,
    ) -> None:
        """Create a datatype restriction."""

    def __getitem__(self, item: FacetRestriction) -> DatatypeRestriction:
        """Return a datatype restriction with an added facet restriction."""

    def __le__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an inclusive maximum datatype restriction."""

    def __lt__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an exclusive maximum datatype restriction."""

    def __ge__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an inclusive minimum datatype restriction."""

    def __gt__(self, val: LiteralValue) -> DatatypeRestriction:
        """Create an exclusive minimum datatype restriction."""

    def datatype(self) -> Datatype:
        """Return the datatype."""

    def restrictions(self) -> Collection[FacetRestriction]:
        """Return the facet restrictions."""

    def that_has(
        self,
        *args: FacetRestriction,
        length: Literal | int | None = None,
        min_length: Literal | int | None = None,
        max_length: Literal | int | None = None,
        value_gt: Literal | LiteralValue | None = None,
        value_ge: Literal | LiteralValue | None = None,
        value_lt: Literal | LiteralValue | None = None,
        value_le: Literal | LiteralValue | None = None,
        pattern: Literal | str | None = None,
        lang_range: Literal | str | None = None,
    ) -> DatatypeRestriction:
        """Create a datatype restriction."""

# Individuals

class Individual(Primitive):
    """Individual."""

    def is_a(self, class_: ClassExpression) -> ClassAssertion:
        """Create a class assertion."""

    def is_same_as(self, *args: Individual) -> SameIndividual:
        """Create an individual equality axiom."""

    def is_different_from(self, *args: Individual) -> DifferentIndividuals:
        """Create an individual inequality axiom."""

class NamedIndividual(Individual, Entity):
    """Named individual."""

    def __init__(self, iri: str | IRI) -> None:
        """Create a named individual."""

class AnonymousIndividual(Individual):
    """Anonymous individual."""

    def __init__(self, node_id: str | None = None) -> None:
        """Create an anonymous individual."""

# Object property expressions

class ObjectPropertyExpression(Object, HasPrimitives):
    """Object property expression."""

    def __call__(self, subject: Individual, object_: Individual) -> ObjectPropertyAssertion:
        """Create an object property assertion."""

    def some(self, filler: ClassExpression) -> ObjectSomeValuesFrom:
        """Create an existential object property restriction."""

    def only(self, filler: ClassExpression) -> ObjectAllValuesFrom:
        """Create a universal object property restriction."""

    def has_value(self, individual: Individual) -> ObjectHasValue:
        """Create a has-value class expression."""

    def has_self(self) -> ObjectHasSelf:
        """Create a self-restriction."""

    def min(
        self,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> ObjectMinCardinality:
        """Create a minimum object property cardinality restriction."""

    def max(
        self,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> ObjectMaxCardinality:
        """Create a maximum object property cardinality restriction."""

    def exactly(
        self,
        cardinality: int,
        filler: ClassExpression | None = None,
    ) -> ObjectExactCardinality:
        """Create an exact object property cardinality restriction."""

    def is_subproperty_of(self, parent: ObjectPropertyExpression) -> SubObjectPropertyOf:
        """Create a sub-object property axiom."""

    def is_equivalent_to(self, *args: ObjectPropertyExpression) -> EquivalentObjectProperties:
        """Create an equivalent object properties axiom."""

    def is_disjoint_with(self, *args: ObjectPropertyExpression) -> DisjointObjectProperties:
        """Create a disjoint object properties axiom."""

    def is_inverse_of(self, other: ObjectPropertyExpression) -> InverseObjectProperties:
        """Create an inverse object properties axiom."""

    def has_domain(self, domain: ClassExpression) -> ObjectPropertyDomain:
        """Create an object property domain axiom."""

    def has_range(self, property_range: ClassExpression) -> ObjectPropertyRange:
        """Create an object property range axiom."""

    def is_functional(self) -> FunctionalObjectProperty:
        """Create a functional object property axiom."""

    def is_inverse_functional(self) -> InverseFunctionalObjectProperty:
        """Create an inverse-functional object property axiom."""

    def is_reflexive(self) -> ReflexiveObjectProperty:
        """Create a reflexive object property axiom."""

    def is_irreflexive(self) -> IrreflexiveObjectProperty:
        """Create an irreflexive object property axiom."""

    def is_symmetric(self) -> SymmetricObjectProperty:
        """Create a symmetric object property axiom."""

    def is_asymmetric(self) -> AsymmetricObjectProperty:
        """Create an asymmetric object property axiom."""

    def is_transitive(self) -> TransitiveObjectProperty:
        """Create a transitive object property axiom."""

class ObjectProperty(ObjectPropertyExpression, Entity):
    """Object property."""

    def __init__(self, iri: str | IRI) -> None:
        """Create an object property."""

    def __invert__(self) -> InverseObjectProperty:
        """Create the inverse object property."""

class InverseObjectProperty(ObjectPropertyExpression):
    """Inverse object property."""

    def __init__(self, property_: ObjectProperty) -> None:
        """Create an inverse object property."""

    def __invert__(self) -> ObjectProperty:
        """Return the underlying object property."""

    def property_(self) -> ObjectProperty:
        """Return the underlying object property."""

class ObjectPropertyChain(Collection[ObjectPropertyExpression]):
    """Object property chain."""

    def is_subproperty_of(self, parent: ObjectPropertyExpression) -> SubObjectPropertyOf:
        """Create a sub-object property axiom."""

# Data property expressions

class DataProperty(Entity):
    """Data property."""

    def __init__(self, iri: str | IRI) -> None:
        """Create a data property."""

    def __call__(
        self,
        subject: Individual,
        value: Literal | LiteralValue,
    ) -> DataPropertyAssertion:
        """Create a data property assertion."""

    def some(self, data_range: DataRange) -> DataSomeValuesFrom:
        """Create an existential data property restriction."""

    def only(self, data_range: DataRange) -> DataAllValuesFrom:
        """Create a universal data property restriction."""

    def has_value(self, value: Literal | LiteralValue) -> DataHasValue:
        """Create a has-value data property restriction."""

    def min(
        self,
        cardinality: int,
        data_range: DataRange | None = None,
    ) -> DataMinCardinality:
        """Create a minimum data property cardinality restriction."""

    def max(
        self,
        cardinality: int,
        data_range: DataRange | None = None,
    ) -> DataMaxCardinality:
        """Create a maximum data property cardinality restriction."""

    def exactly(
        self,
        cardinality: int,
        data_range: DataRange | None = None,
    ) -> DataExactCardinality:
        """Create an exact data property cardinality restriction."""

    def is_subproperty_of(self, parent: DataProperty) -> SubDataPropertyOf:
        """Create a sub-data property axiom."""

    def is_equivalent_to(self, *args: DataProperty) -> EquivalentDataProperties:
        """Create an equivalent data properties axiom."""

    def is_disjoint_with(self, *args: DataProperty) -> DisjointDataProperties:
        """Create a disjoint data properties axiom."""

    def has_domain(self, domain: ClassExpression) -> DataPropertyDomain:
        """Create a data property domain axiom."""

    def has_range(self, property_range: DataRange) -> DataPropertyRange:
        """Create a data property range axiom."""

    def is_functional(self) -> FunctionalDataProperty:
        """Create a functional data property axiom."""

# Axioms

class Axiom(Object, Annotated, HasPrimitives):
    """Axiom."""

class Declaration(Axiom):
    """Declaration axiom."""

    def __init__(
        self,
        entity: Entity,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a declaration axiom."""

    def entity(self) -> Entity:
        """Return the declared entity."""

class SubClassOf(Axiom):
    """Subclass axiom."""

    def __init__(
        self,
        child: ClassExpression,
        parent: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a subclass axiom."""

    def child(self) -> ClassExpression:
        """Return the subclass expression."""

    def parent(self) -> ClassExpression:
        """Return the superclass expression."""

class EquivalentClasses(Axiom):
    """Equivalent classes axiom."""

    def __init__(
        self,
        *args: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an equivalent classes axiom."""

    def classes(self) -> Collection[ClassExpression]:
        """Return the class expressions."""

class DisjointClasses(Axiom):
    """Disjoint classes axiom."""

    def __init__(
        self,
        *args: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a disjoint classes axiom."""

    def classes(self) -> Collection[ClassExpression]:
        """Return the class expressions."""

class DisjointUnion(Axiom):
    """Disjoint union axiom."""

    def __init__(
        self,
        class_: Class,
        *args: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a disjoint union axiom."""

    def class_(self) -> Class:
        """Return the class being defined."""

    def disjoints(self) -> Collection[ClassExpression]:
        """Return the disjoint class expressions."""

class SubObjectPropertyOf(Axiom):
    """Sub-object property axiom."""

    def __init__(
        self,
        child: ObjectPropertyExpression | Iterable[ObjectPropertyExpression],
        parent: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a sub-object property axiom."""

    def child(self) -> ObjectPropertyExpression | ObjectPropertyChain:
        """Return the subproperty expression."""

    def parent(self) -> ObjectPropertyExpression:
        """Return the superproperty expression."""

class EquivalentObjectProperties(Axiom):
    """Equivalent object properties axiom."""

    def __init__(
        self,
        *args: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an equivalent object properties axiom."""

    def properties(self) -> Collection[ObjectPropertyExpression]:
        """Return the object property expressions."""

class DisjointObjectProperties(Axiom):
    """Disjoint object properties axiom."""

    def __init__(
        self,
        *args: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a disjoint object properties axiom."""

    def properties(self) -> Collection[ObjectPropertyExpression]:
        """Return the object property expressions."""

class InverseObjectProperties(Axiom):
    """Inverse object properties axiom."""

    def __init__(
        self,
        first: ObjectPropertyExpression,
        second: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an inverse object properties axiom."""

    def first(self) -> ObjectPropertyExpression:
        """Return the first object property expression."""

    def second(self) -> ObjectPropertyExpression:
        """Return the second object property expression."""

class ObjectPropertyDomain(Axiom, HasObjectProperty):
    """Object property domain axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        domain: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an object property domain axiom."""

    def domain(self) -> ClassExpression:
        """Return the domain class expression."""

class ObjectPropertyRange(Axiom, HasObjectProperty):
    """Object property range axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        property_range: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an object property range axiom."""

    def range(self) -> ClassExpression:
        """Return the range class expression."""

class FunctionalObjectProperty(Axiom, HasObjectProperty):
    """Functional object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a functional object property axiom."""

class InverseFunctionalObjectProperty(Axiom, HasObjectProperty):
    """Inverse-functional object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an inverse-functional object property axiom."""

class ReflexiveObjectProperty(Axiom, HasObjectProperty):
    """Reflexive object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a reflexive object property axiom."""

class IrreflexiveObjectProperty(Axiom, HasObjectProperty):
    """Irreflexive object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an irreflexive object property axiom."""

class SymmetricObjectProperty(Axiom, HasObjectProperty):
    """Symmetric object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a symmetric object property axiom."""

class AsymmetricObjectProperty(Axiom, HasObjectProperty):
    """Asymmetric object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an asymmetric object property axiom."""

class TransitiveObjectProperty(Axiom, HasObjectProperty):
    """Transitive object property axiom."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a transitive object property axiom."""

class SubDataPropertyOf(Axiom):
    """Sub-data property axiom."""

    def __init__(
        self,
        child: DataProperty,
        parent: DataProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a sub-data property axiom."""

    def child(self) -> DataProperty:
        """Return the subproperty."""

    def parent(self) -> DataProperty:
        """Return the superproperty."""

class EquivalentDataProperties(Axiom):
    """Equivalent data properties axiom."""

    def __init__(
        self,
        *args: DataProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an equivalent data properties axiom."""

    def properties(self) -> Collection[DataProperty]:
        """Return the data property expressions."""

class DisjointDataProperties(Axiom):
    """Disjoint data properties axiom."""

    def __init__(
        self,
        *args: DataProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a disjoint data properties axiom."""

    def properties(self) -> Collection[DataProperty]:
        """Return the data property expressions."""

class DataPropertyDomain(Axiom, HasDataProperty):
    """Data property domain axiom."""

    def __init__(
        self,
        property_: DataProperty,
        domain: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a data property domain axiom."""

    def domain(self) -> ClassExpression:
        """Return the domain class expression."""

class DataPropertyRange(Axiom, HasDataProperty):
    """Data property range axiom."""

    def __init__(
        self,
        property_: DataProperty,
        property_range: DataRange,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a data property range axiom."""

    def range(self) -> DataRange:
        """Return the data range."""

class FunctionalDataProperty(Axiom, HasDataProperty):
    """Functional data property axiom."""

    def __init__(
        self,
        property_: DataProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a functional data property axiom."""

class DatatypeDefinition(Axiom):
    """Datatype definition axiom."""

    def __init__(
        self,
        datatype: Datatype,
        data_range: DataRange,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a datatype definition axiom."""

    def datatype(self) -> Datatype:
        """Return the defined datatype."""

    def data_range(self) -> DataRange:
        """Return the data range."""

class HasKey(Axiom):
    """Key axiom."""

    def __init__(
        self,
        class_: ClassExpression,
        object_properties: Iterable[ObjectPropertyExpression],
        data_properties: Iterable[DataProperty],
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a key axiom."""

    def class_(self) -> ClassExpression:
        """Return the key class expression."""

    def object_properties(self) -> Collection[ObjectPropertyExpression]:
        """Return the object property expressions."""

    def data_properties(self) -> Collection[DataProperty]:
        """Return the data property expressions."""

class SameIndividual(Axiom):
    """Individual equality axiom."""

    def __init__(
        self,
        *args: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an individual equality axiom."""

    def individuals(self) -> Collection[Individual]:
        """Return the individuals."""

class DifferentIndividuals(Axiom):
    """Individual inequality axiom."""

    def __init__(
        self,
        *args: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an individual inequality axiom."""

    def individuals(self) -> Collection[Individual]:
        """Return the individuals."""

class ClassAssertion(Axiom):
    """Class assertion."""

    def __init__(
        self,
        class_: ClassExpression,
        individual: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a class assertion."""

    def class_expression(self) -> ClassExpression:
        """Return the class expression."""

    def individual(self) -> Individual:
        """Return the individual."""

class ObjectPropertyAssertion(Axiom, HasObjectProperty):
    """Object property assertion."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        subject: Individual,
        object_: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an object property assertion."""

    def __invert__(self) -> NegativeObjectPropertyAssertion:
        """Create a negative object property assertion."""

    def subject(self) -> Individual:
        """Return the subject individual."""

    def object(self) -> Individual:
        """Return the object individual."""

class NegativeObjectPropertyAssertion(Axiom, HasObjectProperty):
    """Negative object property assertion."""

    def __init__(
        self,
        property_: ObjectPropertyExpression,
        subject: Individual,
        object_: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a negative object property assertion."""

    def __invert__(self) -> ObjectPropertyAssertion:
        """Create a positive object property assertion."""

    def subject(self) -> Individual:
        """Return the subject individual."""

    def object(self) -> Individual:
        """Return the object individual."""

class DataPropertyAssertion(Axiom, HasDataProperty):
    """Data property assertion."""

    def __init__(
        self,
        property_: DataProperty,
        subject: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a data property assertion."""

    def __invert__(self) -> NegativeDataPropertyAssertion:
        """Create a negative data property assertion."""

    def subject(self) -> Individual:
        """Return the subject individual."""

    def value(self) -> Literal:
        """Return the literal."""

class NegativeDataPropertyAssertion(Axiom, HasDataProperty):
    """Negative data property assertion."""

    def __init__(
        self,
        property_: DataProperty,
        subject: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a negative data property assertion."""

    def __invert__(self) -> DataPropertyAssertion:
        """Create a positive data property assertion."""

    def subject(self) -> Individual:
        """Return the subject individual."""

    def value(self) -> Literal:
        """Return the literal."""

class AnnotationAssertion(Axiom, HasAnnotationProperty):
    """Annotation assertion."""

    def __init__(
        self,
        property_: AnnotationProperty,
        subject: AnnotationSubject,
        value: AnnotationValue,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an annotation assertion."""

    def subject(self) -> AnnotationSubject:
        """Return the annotation subject."""

    def value(self) -> AnnotationValue:
        """Return the annotation value."""

class SubAnnotationPropertyOf(Axiom):
    """Sub-annotation property axiom."""

    def __init__(
        self,
        child: AnnotationProperty,
        parent: AnnotationProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create a sub-annotation property axiom."""

    def child(self) -> AnnotationProperty:
        """Return the subproperty."""

    def parent(self) -> AnnotationProperty:
        """Return the superproperty."""

class AnnotationPropertyDomain(Axiom, HasAnnotationProperty):
    """Annotation property domain axiom."""

    def __init__(
        self,
        property_: AnnotationProperty,
        domain: IRI,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an annotation property domain axiom."""

    def domain(self) -> IRI:
        """Return the domain IRI."""

class AnnotationPropertyRange(Axiom, HasAnnotationProperty):
    """Annotation property range axiom."""

    def __init__(
        self,
        property_: AnnotationProperty,
        range_: IRI,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        """Create an annotation property range axiom."""

    def range(self) -> IRI:
        """Return the range IRI."""

# Ontology

class Ontology(Object, Annotated, HasIRI, HasPrimitives, PrimitiveFactory):
    """Ontology."""

    @classmethod
    def at_path(cls, path: Path | str) -> Ontology:
        """Load an ontology from a path."""

    @property
    def prefix_map(self) -> PrefixMap:
        """Return the prefix map."""

    def __init__(self) -> None:
        """Create an empty ontology."""

    def __contains__(self, item: Axiom | Primitive) -> bool:
        """Return whether the ontology contains the given item."""

    def foreach_axiom(
        self,
        func: Callable[[Axiom], None],
        types: Iterable[type[Axiom]] | None = None,
        primitives: Iterable[Object] | None = None,
    ) -> None:
        """Apply a function to each matching axiom."""

    def axioms(
        self,
        types: Iterable[type[Axiom]] | None = None,
        primitives: Iterable[Object] | None = None,
    ) -> Collection[Axiom]:
        """Return the matching axioms."""

    def foreach_related(
        self,
        primitive: Primitive,
        axiom_type: type[Axiom],
        func: Callable[[Primitive], None],
        position: Position = ...,
    ) -> None:
        """Apply a function to each related primitive."""

    def related(
        self,
        primitive: Primitive,
        axiom_type: type[Axiom],
        position: Position = ...,
    ) -> Collection[Primitive]:
        """Return the related primitives."""

    def to_path(self, path: Path | str) -> None:
        """Write the ontology to a path."""

    def set_iri(self, iri: str | IRI, *, update_prefix: bool = False) -> None:
        """
        Set the ontology IRI.

        If `update_prefix` is `True`, also update the default prefix in the ontology
        prefix map to match the new IRI.
        """

    def version(self) -> IRI | None:
        """Return the version IRI, if any."""

    def set_version(self, version: str | IRI) -> None:
        """Set the version IRI."""

    def add(self, *args: Annotation | Axiom | IRI) -> None:
        """Add ontology items."""

    def remove(self, *args: Annotation | Axiom | IRI) -> None:
        """Remove ontology items."""

class PrefixMap(Object, MutableMapping[str, str], PrimitiveFactory):
    """Prefix map."""

    @staticmethod
    def default() -> PrefixMap:
        """Return the default (global) prefix map."""

    def __init__(self) -> None:
        """Create a prefix map."""

    def items_iter(self) -> Iterable[tuple[str, str]]:
        """Iterate over prefix bindings."""

# Vocabularies

class OWL:
    """OWL vocabulary."""

    prefix: str
    ns: str

    backward_compatible_with: AnnotationProperty
    deprecated: AnnotationProperty
    incompatible_with: AnnotationProperty
    prior_version: AnnotationProperty
    version_info: AnnotationProperty

    bottom_data_property: DataProperty
    bottom_object_property: ObjectProperty
    nothing: Class
    rational: Datatype
    real: Datatype
    thing: Class
    top_data_property: DataProperty
    top_object_property: ObjectProperty

class RDF:
    """RDF vocabulary."""

    prefix: str
    ns: str

    lang_range: IRI

    lang_string: Datatype
    plain_literal: Datatype
    xml_literal: Datatype

class RDFS:
    """RDFS vocabulary."""

    prefix: str
    ns: str

    comment: AnnotationProperty
    is_defined_by: AnnotationProperty
    label: AnnotationProperty
    see_also: AnnotationProperty

    literal: Datatype

class XSD:
    """XSD vocabulary."""

    prefix: str
    ns: str

    length: IRI
    max_exclusive: IRI
    max_inclusive: IRI
    max_length: IRI
    min_exclusive: IRI
    min_inclusive: IRI
    min_length: IRI
    pattern: IRI

    any_uri: Datatype
    base64_binary: Datatype
    boolean: Datatype
    byte: Datatype
    date_time: Datatype
    date_time_stamp: Datatype
    decimal: Datatype
    double: Datatype
    float: Datatype
    hex_binary: Datatype
    int: Datatype
    integer: Datatype
    language: Datatype
    long: Datatype
    name: Datatype
    ncname: Datatype
    negative_integer: Datatype
    nmtoken: Datatype
    non_negative_integer: Datatype
    non_positive_integer: Datatype
    normalized_string: Datatype
    positive_integer: Datatype
    short: Datatype
    string: Datatype
    token: Datatype
    unsigned_byte: Datatype
    unsigned_int: Datatype
    unsigned_long: Datatype
    unsigned_short: Datatype
