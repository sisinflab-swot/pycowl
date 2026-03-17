cdef class Ptr:
    cdef void *raw

    @staticmethod
    cdef Ptr retain(void *ptr)

    @staticmethod
    cdef Ptr wrap(void *ptr)

    cdef Ptr copy(self)
