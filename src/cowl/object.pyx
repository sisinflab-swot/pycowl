from __future__ import annotations

from .c cimport cowl_equals, cowl_hash, cowl_to_debug_ustring, cowl_to_ustring
from .ptr cimport Ptr
from .ulib cimport UString, ustring_to_py


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
