"""Entity class."""

from .iri import IRI
from .primitive import Primitive


class Entity(Primitive):
    """An OWL entity."""

    def __init__(self, iri: str | IRI) -> None:
        raise NotImplementedError
