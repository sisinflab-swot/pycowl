from __future__ import annotations

from cowl.c cimport cowl_equals, cowl_to_debug_ustring, cowl_to_ustring
from cowl.ptr cimport Ptr
from cowl.ulib cimport UString, ustring_to_py


cdef class Object:

    def __init__(self, ptr: Ptr):
        self.ptr = ptr

    def __str__(self) -> str:
        cdef UString str_rep = cowl_to_ustring(self.ptr.get())
        return ustring_to_py(&str_rep)

    def __repr__(self) -> str:
        cdef UString str_rep = cowl_to_debug_ustring(self.ptr.get())
        return ustring_to_py(&str_rep)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Object):
            return False
        return <bool>cowl_equals(self.ptr.get(), (<Object>other).ptr.get())
