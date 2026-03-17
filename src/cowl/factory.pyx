from typing import cast, Type

from .c cimport CowlObjectType, cowl_get_type
from .object cimport Object
from .ptr cimport Ptr


TYPES: dict[int, Type[Object]] = {}


cdef inline void set_type(int type_id, type ctype):
    TYPES[type_id] = cast(Type[Object], ctype)


cdef inline void populate_types():
    from .annotation import Annotation
    from .annotation_property import AnnotationProperty
    from .anonymous_individual import AnonymousIndividual
    from .collection import Collection
    from .data_property import DataProperty
    from .datatype import Datatype
    from .iri import IRI
    from .literal import Literal
    from .named_individual import NamedIndividual
    from .ontology import Ontology
    from .owlclass import Class

    set_type(CowlObjectType.COWL_OT_ANNOTATION, Annotation)
    set_type(CowlObjectType.COWL_OT_ANNOT_PROP, AnnotationProperty)
    set_type(CowlObjectType.COWL_OT_I_ANONYMOUS, AnonymousIndividual)
    set_type(CowlObjectType.COWL_OT_VECTOR, Collection)
    set_type(CowlObjectType.COWL_OT_DPE_DATA_PROP, DataProperty)
    set_type(CowlObjectType.COWL_OT_DR_DATATYPE, Datatype)
    set_type(CowlObjectType.COWL_OT_IRI, IRI)
    set_type(CowlObjectType.COWL_OT_LITERAL, Literal)
    set_type(CowlObjectType.COWL_OT_I_NAMED, NamedIndividual)
    set_type(CowlObjectType.COWL_OT_ONTOLOGY, Ontology)
    set_type(CowlObjectType.COWL_OT_CE_CLASS, Class)


cdef concrete_type(void *ptr):
    if not TYPES:
        populate_types()
    return TYPES.get(<int>cowl_get_type(ptr), Object)


cdef Object wrap(void *ptr):
    ctype = concrete_type(ptr)
    cdef Object obj = ctype.__new__(ctype)
    obj.ptr = Ptr.wrap(ptr)
    return obj


cdef Object retain(void *ptr):
    ctype = concrete_type(ptr)
    cdef Object obj = ctype.__new__(ctype)
    obj.ptr = Ptr.retain(ptr)
    return obj
