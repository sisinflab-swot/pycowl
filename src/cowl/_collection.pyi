from collections.abc import Collection as ABCCollection

from ._object import Object

class Collection[T: Object](Object, ABCCollection[T]): ...
