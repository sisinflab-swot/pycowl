# type: ignore

from ._ptr cimport Ptr


cdef class Object:
    cdef Ptr _ptr

    cdef inline void *ptr(self):
        return self._ptr.raw

    cdef inline void set_ptr(self, Ptr ptr):
        self._ptr = ptr
