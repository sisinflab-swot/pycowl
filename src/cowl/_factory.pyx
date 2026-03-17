from typing import cast, Type

from ._c cimport CowlObjectType, cowl_get_type
from ._object cimport Object
from ._ptr cimport Ptr


TYPES: dict[int, Type[Object]] = {}


cdef inline void set_type(int type_id, type ctype):
    TYPES[type_id] = cast(Type[Object], ctype)


cdef inline void populate_types():
    from ._annotation import Annotation
    from ._annotation_property import AnnotationProperty
    from ._anonymous_individual import AnonymousIndividual
    from ._collection import Collection
    from ._data_property import DataProperty
    from ._datatype import Datatype
    from ._iri import IRI
    from ._literal import Literal
    from ._named_individual import NamedIndividual
    from ._ontology import Ontology
    from ._owlclass import Class

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
