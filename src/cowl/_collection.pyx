from collections.abc import Iterator

from . cimport _factory as factory
from ._c cimport CowlVector, cowl_vector_contains, cowl_vector_count, cowl_vector_get_item
from ._object cimport Object


cdef class Collection(Object):

    def __len__(self) -> int:
        return cowl_vector_count(<CowlVector *>self.raw_ptr())

    def __contains__(self, item: object) -> bool:
        if not isinstance(item, Object):
            return False
        return <bool>cowl_vector_contains(<CowlVector *>self.raw_ptr(), (<Object>item).raw_ptr())

    def __iter__(self) -> Iterator[Object]:
        cdef CowlVector *vec = <CowlVector *>self.raw_ptr()
        cdef int count = cowl_vector_count(vec)
        for i in range(count):
            yield factory.retain(cowl_vector_get_item(vec, i))
