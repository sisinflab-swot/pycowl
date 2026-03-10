from cowl.c cimport cowl_retain, cowl_release


cdef class Ptr:

    @staticmethod
    cdef Ptr retain(void *ptr):
        p = Ptr()
        p.ptr = cowl_retain(ptr)
        return p

    @staticmethod
    cdef Ptr wrap(void *ptr):
        p = Ptr()
        p.ptr = ptr
        return p

    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            cowl_release(self.ptr)
