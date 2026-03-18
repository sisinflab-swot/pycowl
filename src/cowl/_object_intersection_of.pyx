from collections.abc import Iterable

from . cimport _factory as factory
from ._c cimport (
    CowlNAryBool,
    CowlNAryType,
    cowl_nary_bool,
    cowl_nary_bool_get_operands,
    cowl_vector_from_py,
)
from ._class_expression import ClassExpression
from ._collection cimport Collection
from ._object cimport Object
from ._ptr cimport Ptr


cdef class ObjectIntersectionOf(Object):

    def __init__(self, operands: Iterable[ClassExpression]) -> None:
        cdef CowlNAryType ctype = <CowlNAryType>CowlNAryType.COWL_NT_INTERSECT
        cdef void *ptr = <void *>cowl_nary_bool(ctype, cowl_vector_from_py(operands))
        super().__init__(Ptr.wrap(ptr))

    def operands(self) -> Collection:
        cdef void *ops = <void *>cowl_nary_bool_get_operands(<CowlNAryBool *>self.raw_ptr())
        return <Collection>factory.retain(ops)
