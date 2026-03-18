from collections.abc import Iterable

from ._annotation import Annotation
from ._object import Object
from ._types import ClassExpression

class SubClassOf(Object):
    def __init__(
        self,
        sub_class: ClassExpression,
        super_class: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None: ...
