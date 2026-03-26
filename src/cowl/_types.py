from ._wrap import (
    IRI,
    AnonymousIndividual,
    Literal,
)

type AnnotationValue = IRI | Literal | AnonymousIndividual
type LiteralValue = str | int | float | bool
