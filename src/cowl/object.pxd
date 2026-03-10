from cowl.ptr cimport Ptr


cdef class Object:
    cdef Ptr ptr
