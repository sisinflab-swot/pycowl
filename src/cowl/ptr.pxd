cdef class Ptr:
    cdef void *ptr

    @staticmethod
    cdef Ptr retain(void *ptr)

    @staticmethod
    cdef Ptr wrap(void *ptr)

    cdef inline void *get(self):
        return self.ptr
