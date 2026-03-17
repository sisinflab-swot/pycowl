from .object import Object

class IRI(Object):
    def __init__(self, prefix: str, suffix: str | None = None) -> None: ...
