# type: ignore

from __future__ import annotations

from pathlib import Path

from . cimport _factory as factory
from ._c cimport (
    CowlIRI,
    CowlIterator,
    CowlOntology,
    UVec_CowlObjectPtr,
    cowl_iterator_vec,
    cowl_ontology,
    cowl_ontology_add_axiom,
    cowl_ontology_at_path,
    cowl_ontology_iterate_axioms,
    cowl_ontology_remove_axiom,
    cowl_ontology_set_iri,
    cowl_ontology_to_path,
    cowl_ontology_to_stream,
    cowl_vector,
    uvec_CowlObjectPtr,
)
from ._collection cimport Collection
from ._iri cimport IRI
from ._object cimport Object
from ._ptr cimport Ptr
from ._ulib cimport (
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
        cdef void *ptr = cowl_ontology_at_path(path_str)

        if not ptr:
            msg = f"Failed to load ontology at path: {path}"
            raise ValueError(msg)

        return factory.wrap(ptr)

    def __init__(self) -> None:
        super().__init__(Ptr.wrap(cowl_ontology()))

    def __str__(self) -> str:
        cdef UStrBuf buf = ustrbuf()
        cdef UOStream stream
        uostream_to_strbuf(&stream, &buf)
        cowl_ontology_to_stream(<CowlOntology *>self.ptr(), &stream)
        uostream_deinit(&stream)
        return ustrbuf_to_py(&buf)

    def to_path(self, path: Path | str) -> None:
        cdef UString path_str = ustring_from_py(path if isinstance(path, str) else str(path))
        cowl_ontology_to_path(<CowlOntology *>self.ptr(), path_str)
        ustring_deinit(&path_str)

    def set_iri(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        cowl_ontology_set_iri(<CowlOntology *>self.ptr(), <CowlIRI *>iri_obj.ptr())

    def axioms(self) -> Collection:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, False)
        cowl_ontology_iterate_axioms(<CowlOntology *>self.ptr(), &iter)
        return factory.wrap(cowl_vector(&vec))

    def add_axiom(self, axiom: Object) -> None:
        cowl_ontology_add_axiom(<CowlOntology *>self.ptr(), axiom.ptr())

    def remove_axiom(self, axiom: Object) -> None:
        cowl_ontology_remove_axiom(<CowlOntology *>self.ptr(), axiom.ptr())
