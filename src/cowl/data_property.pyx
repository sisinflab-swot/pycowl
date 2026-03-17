from .c cimport CowlIRI, cowl_data_prop
from .iri cimport IRI
from .object cimport Object
from .ptr cimport Ptr


cdef class DataProperty(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        cdef void *ptr = <void *>cowl_data_prop(<CowlIRI *>iri_obj.raw_ptr())
        super().__init__(Ptr.wrap(ptr))
