from collections.abc import Iterator

from . cimport factory
from .c cimport CowlVector, cowl_vector_contains, cowl_vector_count, cowl_vector_get_item
from .object cimport Object
from .ptr cimport Ptr


cdef class Collection(Object):

    def __init__(self, ptr: Ptr):
        super().__init__(ptr)

    def __len__(self) -> int:
        return cowl_vector_count(<CowlVector *>self.ptr.raw)

    def __contains__(self, item: object) -> bool:
        if not isinstance(item, Object):
            return False
        return <bool>cowl_vector_contains(<CowlVector *>self.ptr.raw, (<Object>item).ptr.raw)

    def __iter__(self) -> Iterator[Object]:
        cdef CowlVector *vec = <CowlVector *>self.ptr.raw
        cdef int count = cowl_vector_count(vec)
        for i in range(count):
            yield factory.retained(cowl_vector_get_item(vec, i))
