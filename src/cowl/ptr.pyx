from .c cimport cowl_retain, cowl_release


cdef class Ptr:

    @staticmethod
    cdef Ptr wrap(void *ptr):
        cdef Ptr p = Ptr.__new__(Ptr)
        p.raw = ptr
        return p

    @staticmethod
    cdef Ptr retain(void *ptr):
        return Ptr.wrap(cowl_retain(ptr))

    def __cinit__(self):
        self.raw = NULL

    def __init__(self):
        raise TypeError("Ptr cannot be instantiated directly.")

    def __dealloc__(self):
        if self.raw:
            cowl_release(self.raw)

    cdef Ptr copy(self):
        return Ptr.retain(self.raw)
