from ._iri import IRI
from ._primitive import Primitive


class Entity(Primitive):
    def __init__(self, iri: str | IRI) -> None:
        raise NotImplementedError
