from collections.abc import Collection as ABCCollection

from .object import Object

class Collection[T: Object](Object, ABCCollection[T]): ...
