from __future__ import annotations

from pathlib import Path

from . cimport factory
from .c cimport (
    CowlIterator,
    CowlOntology,
    UVec_CowlObjectPtr,
    cowl_iterator_vec,
    cowl_ontology,
    cowl_ontology_at_path,
    cowl_ontology_iterate_axioms,
    cowl_ontology_to_path,
    cowl_ontology_to_stream,
    cowl_vector,
    uvec_CowlObjectPtr,
)
from .collection cimport Collection
from .object cimport Object
from .ptr cimport Ptr
from .ulib cimport (
    UOStream,
    UStrBuf,
    UString,
    uostream_to_strbuf,
    uostream_deinit,
    ustrbuf,
    ustrbuf_to_py,
    ustring_deinit,
    ustring_from_py,
)

cdef class Ontology(Object):

    @classmethod
    def at_path(cls, path: Path | str) -> Ontology:
        cdef UString path_str = ustring_from_py(path if isinstance(path, str) else str(path))
        cdef void *ptr = <void *>cowl_ontology_at_path(path_str)

        if not ptr:
            msg = f"Failed to load ontology at path: {path}"
            raise ValueError(msg)

        return <Ontology>factory.wrap(ptr)

    def __init__(self) -> None:
        super().__init__(Ptr.wrap(<void *>cowl_ontology()))

    def __str__(self) -> str:
        cdef UStrBuf buf = ustrbuf()
        cdef UOStream stream
        uostream_to_strbuf(&stream, &buf)
        cowl_ontology_to_stream(<CowlOntology *>self.ptr.raw, &stream)
        uostream_deinit(&stream)
        return ustrbuf_to_py(&buf)

    def to_path(self, path: Path | str) -> None:
        cdef UString path_str = ustring_from_py(path if isinstance(path, str) else str(path))
        cowl_ontology_to_path(<CowlOntology *>self.ptr.raw, path_str)
        ustring_deinit(&path_str)

    def axioms(self) -> Collection:
        cdef CowlOntology *onto = <CowlOntology *>self.ptr.raw
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, <bint>False)
        cowl_ontology_iterate_axioms(onto, &iter)
        return <Collection>factory.wrap(<void *>cowl_vector(&vec))
