from ._c cimport CowlIRI, cowl_datatype
from ._iri cimport IRI
from ._object cimport Object
from ._ptr cimport Ptr


cdef class Datatype(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        cdef void *ptr = <void *>cowl_datatype(<CowlIRI *>iri_obj.raw_ptr())
        super().__init__(Ptr.wrap(ptr))
