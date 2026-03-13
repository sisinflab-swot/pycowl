from .object cimport Object

cdef Object new(void *ptr)
cdef Object retained(void *ptr)
