from ._wrap import (
    IRI,
    AnnotationProperty,
    AnonymousIndividual,
    Class,
    ClassAssertion,
    DataProperty,
    Datatype,
    InverseObjectProperty,
    Literal,
    NamedIndividual,
    ObjectAllValuesFrom,
    ObjectIntersectionOf,
    ObjectProperty,
    ObjectSomeValuesFrom,
    ObjectUnionOf,
    SubClassOf,
)

type Axiom = SubClassOf | ClassAssertion
type ClassExpression = (
    Class | ObjectIntersectionOf | ObjectUnionOf | ObjectAllValuesFrom | ObjectSomeValuesFrom
)
type AnnotationValue = IRI | Literal | AnonymousIndividual
type DataPropertyExpression = DataProperty
type Entity = (
    Class | Datatype | ObjectProperty | DataProperty | AnnotationProperty | NamedIndividual
)
type ObjectPropertyExpression = ObjectProperty | InverseObjectProperty
type Primitive = Entity | AnonymousIndividual
type Individual = NamedIndividual | AnonymousIndividual
