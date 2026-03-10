from __future__ import annotations

from pathlib import Path

from cowl.c cimport (
    CowlOntology,
    cowl_ontology,
    cowl_ontology_at_path,
    cowl_ontology_to_stream,
)
from cowl.object cimport Object
from cowl.ptr cimport Ptr
from cowl.ulib cimport (
    UOStream,
    UStrBuf,
    UString,
    uostream_to_strbuf,
    uostream_deinit,
    ustrbuf,
    ustrbuf_to_py,
    ustring_from_py,
)

cdef class Ontology(Object):

    @classmethod
    def empty(cls) -> Ontology:
        cdef void *ptr = <void *>cowl_ontology()
        return Ontology(Ptr.wrap(ptr))

    @classmethod
    def at_path(cls, path: Path | str) -> Ontology:
        cdef UString path_str = ustring_from_py(path if isinstance(path, str) else str(path))
        cdef void *ptr = <void *>cowl_ontology_at_path(path_str)

        if not ptr:
            msg = f"Failed to load ontology at path: {path}"
            raise ValueError(msg)

        return Ontology(Ptr.wrap(ptr))

    def __init__(self, ptr: Ptr):
        super().__init__(ptr)

    def as_string(self) -> str:
        cdef UStrBuf buf = ustrbuf()
        cdef UOStream stream
        uostream_to_strbuf(&stream, &buf)
        cowl_ontology_to_stream(<CowlOntology *>self.ptr.get(), &stream)
        uostream_deinit(&stream)
        return ustrbuf_to_py(&buf)
