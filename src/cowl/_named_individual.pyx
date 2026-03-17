from ._c cimport CowlIRI, cowl_named_ind
from ._iri cimport IRI
from ._object cimport Object
from ._ptr cimport Ptr


cdef class NamedIndividual(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        cdef void *ptr = <void *>cowl_named_ind(<CowlIRI *>iri_obj.raw_ptr())
        super().__init__(Ptr.wrap(ptr))
