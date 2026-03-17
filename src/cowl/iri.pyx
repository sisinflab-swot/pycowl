from .c cimport (
    CowlIRI,
    CowlString,
    cowl_iri,
    cowl_iri_from_string,
    cowl_iri_get_ns,
    cowl_iri_get_rem,
    cowl_release,
    cowl_string_from_py,
    cowl_string_to_py,
)
from .primitive cimport Primitive
from .ptr cimport Ptr
from .ulib cimport UString, ustring_from_py, ustring_deinit


cdef class IRI(Primitive):

    @property
    def namespace(self) -> str:
        return cowl_string_to_py(cowl_iri_get_ns(<CowlIRI *>self.ptr.raw))

    @property
    def remainder(self) -> str:
        return cowl_string_to_py(cowl_iri_get_rem(<CowlIRI *>self.ptr.raw))

    def __str__(self) -> str:
        return self.namespace + self.remainder

    def __init__(self, prefix: str, suffix: str | None = None) -> None:
        cdef void *ptr
        if suffix is None:
            ptr = _iri_from_str(prefix)
        else:
            ptr = _iri_from_prefix_suffix(prefix, suffix)
        super().__init__(Ptr.wrap(ptr))


cdef void *_iri_from_str(str s):
    cdef UString u_str = ustring_from_py(s)
    cdef void *ret = <void *>cowl_iri_from_string(u_str)
    ustring_deinit(&u_str)
    return ret


cdef void *_iri_from_prefix_suffix(str prefix, str suffix):
    cdef CowlString *c_prefix = cowl_string_from_py(prefix)
    cdef CowlString *c_suffix = cowl_string_from_py(suffix)
    cdef void *ret = <void *>cowl_iri(c_prefix, c_suffix)
    cowl_release(<void *>c_prefix)
    cowl_release(<void *>c_suffix)
    return ret
