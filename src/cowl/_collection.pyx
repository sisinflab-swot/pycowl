# type: ignore

from collections.abc import Iterable, Iterator

from . cimport _factory as factory
from ._c cimport (
    CowlVector,
    cowl_vector_from_py,
    cowl_vector_contains,
    cowl_vector_count,
    cowl_vector_get_item,
)
from ._object cimport Object
from ._ptr cimport Ptr


cdef class Collection(Object):

    def __init__(self, items: Iterable[Object]) -> None:
        super().__init__(Ptr.wrap(cowl_vector_from_py(items)))

    def __len__(self) -> int:
        return cowl_vector_count(<CowlVector *>self.ptr())

    def __contains__(self, item: object) -> bool:
        if not isinstance(item, Object):
            return False
        return cowl_vector_contains(<CowlVector *>self.ptr(), (<Object>item).ptr())

    def __iter__(self) -> Iterator[Object]:
        cdef CowlVector *vec = <CowlVector *>self.ptr()
        cdef int count = cowl_vector_count(vec)
        cdef int i
        for i in range(count):
            yield factory.retain(cowl_vector_get_item(vec, i))
