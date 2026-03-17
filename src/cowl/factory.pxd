from .object cimport Object

cdef Object wrap(void *ptr)
cdef Object retain(void *ptr)
