# type: ignore

from collections.abc import Iterable

from . cimport _factory as factory
from ._c cimport (
    CowlNAryBool,
    CowlNAryType,
    cowl_nary_bool,
    cowl_nary_bool_get_operands,
    cowl_vector_from_py,
)
from ._collection cimport Collection
from ._object cimport Object
from ._ptr cimport Ptr


cdef class ObjectIntersectionOf(Object):

    def __init__(self, operands: Iterable[Object]) -> None:
        cdef CowlNAryType ctype = CowlNAryType.COWL_NT_INTERSECT
        super().__init__(Ptr.wrap(cowl_nary_bool(ctype, cowl_vector_from_py(operands))))

    def operands(self) -> Collection:
        return factory.retain(cowl_nary_bool_get_operands(<CowlNAryBool *>self.ptr()))
