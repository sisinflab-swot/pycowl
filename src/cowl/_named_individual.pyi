from ._iri import IRI
from ._object import Object

class NamedIndividual(Object):
    def __init__(self, iri: str | IRI) -> None: ...
