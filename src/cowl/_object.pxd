from ._ptr cimport Ptr


cdef class Object:
    cdef Ptr ptr

    cdef inline void *raw_ptr(self):
        return self.ptr.raw
