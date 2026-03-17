from .c cimport CowlIRI, cowl_class

from .iri cimport IRI
from .object cimport Object
from .ptr cimport Ptr


cdef class Class(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        cdef void *ptr = <void *>cowl_class(<CowlIRI *>iri_obj.raw_ptr())
        super().__init__(Ptr.wrap(ptr))
