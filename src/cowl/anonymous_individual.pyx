from .c cimport CowlString, cowl_anon_ind, cowl_string_from_py
from .object cimport Object
from .ptr cimport Ptr


cdef class AnonymousIndividual(Object):
    def __init__(self, node_id: str | None = None) -> None:
        cdef CowlString *c_str = cowl_string_from_py(node_id) if node_id else <CowlString *>NULL
        cdef void *ptr = <void *>cowl_anon_ind(c_str)
        super().__init__(Ptr.wrap(ptr))
