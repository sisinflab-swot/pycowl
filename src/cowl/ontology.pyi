from pathlib import Path

from cowl.object import Object

class Ontology(Object):
    @classmethod
    def empty(cls) -> Ontology: ...
    @classmethod
    def at_path(cls, path: Path | str) -> Ontology: ...
    def as_string(self) -> str: ...
