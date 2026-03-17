from . cimport _factory as factory

from ._c cimport (
    CowlString,
    cowl_equals,
    cowl_get_annot,
    cowl_get_iri,
    cowl_get_ns,
    cowl_get_rem,
    cowl_hash,
    cowl_to_debug_ustring,
    cowl_to_ustring,
    cowl_string_to_py,
)

from ._collection cimport Collection
from ._iri cimport IRI
from ._ptr cimport Ptr
from ._ulib cimport UString, ustring_to_py


cdef class Object:

    def __init__(self, ptr: Ptr) -> None:
        self.ptr = ptr

    def __str__(self) -> str:
        cdef UString str_rep = cowl_to_ustring(self.ptr.raw)
        return ustring_to_py(&str_rep)

    def __repr__(self) -> str:
        cdef UString str_rep = cowl_to_debug_ustring(self.ptr.raw)
        return ustring_to_py(&str_rep)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Object):
            return False
        return <bool>cowl_equals(self.ptr.raw, (<Object>other).ptr.raw)

    def __hash__(self) -> int:
        return cowl_hash(self.ptr.raw)

    def iri(self) -> IRI:
        cdef void *iri_ptr = <void *>cowl_get_iri(self.ptr.raw)

        if not iri_ptr:
            raise TypeError("Object does not have an IRI")

        return <IRI>factory.retain(iri_ptr)

    def namespace(self) -> str:
        cdef CowlString *ns_ptr = cowl_get_ns(self.ptr.raw)

        if not ns_ptr:
            raise TypeError("Object does not have a namespace")

        return cowl_string_to_py(ns_ptr)

    def remainder(self) -> str:
        cdef CowlString *rem_ptr = cowl_get_rem(self.ptr.raw)

        if not rem_ptr:
            raise TypeError("Object does not have a remainder")

        return cowl_string_to_py(rem_ptr)

    def annotations(self) -> Collection:
        return <Collection>factory.retain(<void *>cowl_get_annot(self.ptr.raw))
