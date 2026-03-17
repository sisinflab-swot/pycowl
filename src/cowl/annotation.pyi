from .annotation_property import AnnotationProperty
from .anonymous_individual import AnonymousIndividual
from .iri import IRI
from .literal import Literal
from .object import Object

class Annotation(Object):
    def property(self) -> AnnotationProperty: ...
    def value(self) -> IRI | Literal | AnonymousIndividual: ...
