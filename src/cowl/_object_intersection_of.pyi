from collections.abc import Iterable

from ._collection import Collection
from ._object import Object
from ._types import ClassExpression

class ObjectIntersectionOf(Object):
    def __init__(self, operands: Iterable[ClassExpression]) -> None: ...
    def operands(self) -> Collection[ClassExpression]: ...
