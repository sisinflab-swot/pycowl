from ._wrap import (
    IRI,
    AnnotationProperty,
    AnonymousIndividual,
    Class,
    DataProperty,
    Datatype,
    Literal,
    NamedIndividual,
    ObjectProperty,
)

type AnnotationValue = IRI | Literal | AnonymousIndividual
type Entity = (
    Class | Datatype | ObjectProperty | DataProperty | AnnotationProperty | NamedIndividual
)
type LiteralValue = str | int | float | bool
type Primitive = Entity | AnonymousIndividual
