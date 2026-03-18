from collections.abc import Collection as ABCCollection, Iterable

from ._object import Object

class Collection[T: Object](Object, ABCCollection[T]):
    def __init__(self, items: Iterable[T]) -> None: ...
