from ._annotation_property import AnnotationProperty
from ._anonymous_individual import AnonymousIndividual
from ._iri import IRI
from ._literal import Literal
from ._object import Object

class Annotation(Object):
    def property(self) -> AnnotationProperty: ...
    def value(self) -> IRI | Literal | AnonymousIndividual: ...
