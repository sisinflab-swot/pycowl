from .c cimport CowlString, cowl_init, cowl_string, cowl_string_get_raw
from .ulib cimport ustring_from_py, ustring_to_py


cowl_init()


cdef CowlString *cowl_string_from_py(str s):
    return cowl_string(ustring_from_py(s))


cdef str cowl_string_to_py(CowlString *s):
    return ustring_to_py(cowl_string_get_raw(s), deinit=False)
