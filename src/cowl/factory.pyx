from .object cimport Object
from .ptr cimport Ptr


cdef Object new(void *ptr):
    return Object(Ptr.wrap(ptr))


cdef Object retained(void *ptr):
    return Object(Ptr.retain(ptr))
