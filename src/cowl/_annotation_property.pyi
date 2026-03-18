from ._iri import IRI
from ._object import Object

class AnnotationProperty(Object):
    def __init__(self, iri: str | IRI) -> None: ...
