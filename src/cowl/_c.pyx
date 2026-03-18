from collections.abc import Iterable
from ._c cimport (
    CowlObject,
    CowlString,
    CowlVector,
    UVec_CowlObjectPtr,
    cowl_init,
    cowl_string,
    cowl_string_get_raw,
    cowl_vector,
    uvec_CowlObjectPtr,
    uvec_push_CowlObjectPtr,
)
from ._object cimport Object
from ._ulib cimport ustring_from_py, ustring_to_py


cowl_init()


cdef CowlString *cowl_string_from_py(str s):
    return cowl_string(ustring_from_py(s))


cdef str cowl_string_to_py(CowlString *s):
    return ustring_to_py(cowl_string_get_raw(s), deinit=False)


cdef CowlVector *cowl_vector_from_py(items: Iterable[Object]):
    cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
    for item in items:
        uvec_push_CowlObjectPtr(&vec, <CowlObject *>(<Object>item).ptr())
    return cowl_vector(&vec)
