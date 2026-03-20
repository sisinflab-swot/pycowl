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
type Primitive = Entity | AnonymousIndividual
type Individual = NamedIndividual | AnonymousIndividual
