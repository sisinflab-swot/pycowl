# type: ignore
import os
from collections.abc import Collection as ABCCollection, Iterable, MutableMapping
from cpython.ref cimport Py_INCREF, Py_DECREF
from datetime import date, datetime
from enum import IntFlag
from io import IOBase
from libc.errno cimport errno
from libc.string cimport memcpy
from pathlib import Path
from typing import NoReturn, Protocol, TypeAlias, Union, overload

from ._c_api cimport *


cowl_init()  # Trigger native library initialization on import.


# Type mappings


Types: TypeAlias = Union[type, tuple[type, ...]]
OneOrMany: TypeAlias

LiteralValue: TypeAlias = Union[str, int, float, bool, date, datetime]
AnnotationSubject: TypeAlias = Union['IRI', 'AnonymousIndividual']
AnnotationValue: TypeAlias = Union['IRI', 'Literal', 'AnonymousIndividual']


cdef list[type[Object]] _TYPES
cdef dict[type[Object], CowlObjectType] _TYPES_R
cdef dict[str, tuple[IRI, Datatype]] _FACETS


cdef void _init():
    global _TYPES, _TYPES_R, _FACETS
    _TYPES = [Object] * CowlObjectType.COWL_OT_COUNT
    _TYPES[CowlObjectType.COWL_OT_VECTOR] = Collection
    _TYPES[CowlObjectType.COWL_OT_IRI] = IRI
    _TYPES[CowlObjectType.COWL_OT_LITERAL] = Literal
    _TYPES[CowlObjectType.COWL_OT_FACET_RESTR] = FacetRestriction
    _TYPES[CowlObjectType.COWL_OT_ONTOLOGY] = Ontology
    _TYPES[CowlObjectType.COWL_OT_PREFIX_MAP] = PrefixMap
    _TYPES[CowlObjectType.COWL_OT_READER] = Reader
    _TYPES[CowlObjectType.COWL_OT_WRITER] = Writer
    _TYPES[CowlObjectType.COWL_OT_ANNOTATION] = Annotation
    _TYPES[CowlObjectType.COWL_OT_ANNOT_PROP] = AnnotationProperty
    _TYPES[CowlObjectType.COWL_OT_A_DECL] = Declaration
    _TYPES[CowlObjectType.COWL_OT_A_SUB_CLASS] = SubClassOf
    _TYPES[CowlObjectType.COWL_OT_A_EQUIV_CLASSES] = EquivalentClasses
    _TYPES[CowlObjectType.COWL_OT_A_DISJ_CLASSES] = DisjointClasses
    _TYPES[CowlObjectType.COWL_OT_A_DISJ_UNION] = DisjointUnion
    _TYPES[CowlObjectType.COWL_OT_A_SUB_OBJ_PROP] = SubObjectPropertyOf
    _TYPES[CowlObjectType.COWL_OT_A_EQUIV_OBJ_PROP] = EquivalentObjectProperties
    _TYPES[CowlObjectType.COWL_OT_A_DISJ_OBJ_PROP] = DisjointObjectProperties
    _TYPES[CowlObjectType.COWL_OT_A_INV_OBJ_PROP] = InverseObjectProperties
    _TYPES[CowlObjectType.COWL_OT_A_OBJ_PROP_DOMAIN] = ObjectPropertyDomain
    _TYPES[CowlObjectType.COWL_OT_A_OBJ_PROP_RANGE] = ObjectPropertyRange
    _TYPES[CowlObjectType.COWL_OT_A_FUNC_OBJ_PROP] = FunctionalObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_INV_FUNC_OBJ_PROP] = InverseFunctionalObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_REFL_OBJ_PROP] = ReflexiveObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_IRREFL_OBJ_PROP] = IrreflexiveObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_SYMM_OBJ_PROP] = SymmetricObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_ASYMM_OBJ_PROP] = AsymmetricObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_TRANS_OBJ_PROP] = TransitiveObjectProperty
    _TYPES[CowlObjectType.COWL_OT_A_SUB_DATA_PROP] = SubDataPropertyOf
    _TYPES[CowlObjectType.COWL_OT_A_EQUIV_DATA_PROP] = EquivalentDataProperties
    _TYPES[CowlObjectType.COWL_OT_A_DISJ_DATA_PROP] = DisjointDataProperties
    _TYPES[CowlObjectType.COWL_OT_A_DATA_PROP_DOMAIN] = DataPropertyDomain
    _TYPES[CowlObjectType.COWL_OT_A_DATA_PROP_RANGE] = DataPropertyRange
    _TYPES[CowlObjectType.COWL_OT_A_FUNC_DATA_PROP] = FunctionalDataProperty
    _TYPES[CowlObjectType.COWL_OT_A_DATATYPE_DEF] = DatatypeDefinition
    _TYPES[CowlObjectType.COWL_OT_A_HAS_KEY] = HasKey
    _TYPES[CowlObjectType.COWL_OT_A_SAME_IND] = SameIndividual
    _TYPES[CowlObjectType.COWL_OT_A_DIFF_IND] = DifferentIndividuals
    _TYPES[CowlObjectType.COWL_OT_A_CLASS_ASSERT] = ClassAssertion
    _TYPES[CowlObjectType.COWL_OT_A_OBJ_PROP_ASSERT] = ObjectPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_NEG_OBJ_PROP_ASSERT] = NegativeObjectPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_DATA_PROP_ASSERT] = DataPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_NEG_DATA_PROP_ASSERT] = NegativeDataPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_ANNOT_ASSERT] = AnnotationAssertion
    _TYPES[CowlObjectType.COWL_OT_A_SUB_ANNOT_PROP] = SubAnnotationPropertyOf
    _TYPES[CowlObjectType.COWL_OT_A_ANNOT_PROP_DOMAIN] = AnnotationPropertyDomain
    _TYPES[CowlObjectType.COWL_OT_A_ANNOT_PROP_RANGE] = AnnotationPropertyRange
    _TYPES[CowlObjectType.COWL_OT_CE_CLASS] = Class
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_INTERSECT] = ObjectIntersectionOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_UNION] = ObjectUnionOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_COMPL] = ObjectComplementOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_ONE_OF] = ObjectOneOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_SOME] = ObjectSomeValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_ALL] = ObjectAllValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_HAS_VALUE] = ObjectHasValue
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_HAS_SELF] = ObjectHasSelf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_MIN_CARD] = ObjectMinCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_MAX_CARD] = ObjectMaxCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_EXACT_CARD] = ObjectExactCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_SOME] = DataSomeValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_ALL] = DataAllValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_HAS_VALUE] = DataHasValue
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_MIN_CARD] = DataMinCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_MAX_CARD] = DataMaxCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_EXACT_CARD] = DataExactCardinality
    _TYPES[CowlObjectType.COWL_OT_DR_DATATYPE] = Datatype
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_INTERSECT] = DataIntersectionOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_UNION] = DataUnionOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_COMPL] = DataComplementOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_ONE_OF] = DataOneOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATATYPE_RESTR] = DatatypeRestriction
    _TYPES[CowlObjectType.COWL_OT_OPE_OBJ_PROP] = ObjectProperty
    _TYPES[CowlObjectType.COWL_OT_OPE_INV_OBJ_PROP] = InverseObjectProperty
    _TYPES[CowlObjectType.COWL_OT_DPE_DATA_PROP] = DataProperty
    _TYPES[CowlObjectType.COWL_OT_I_NAMED] = NamedIndividual
    _TYPES[CowlObjectType.COWL_OT_I_ANONYMOUS] = AnonymousIndividual
    _TYPES_R = {t: i for i, t in enumerate(_TYPES)}
    _FACETS = {
        "length": (XSD.length, XSD.non_negative_integer),
        "min_length": (XSD.min_length, XSD.non_negative_integer),
        "max_length": (XSD.max_length, XSD.non_negative_integer),
        "value_gt": (XSD.min_exclusive, None),
        "value_ge": (XSD.min_inclusive, None),
        "value_lt": (XSD.max_exclusive, None),
        "value_le": (XSD.max_inclusive, None),
        "pattern": (XSD.pattern, XSD.string),
        "lang_range": (RDF.lang_range, XSD.string),
    }


cdef inline _py_type(CowlObjectType t):
    return _TYPES[<int>t]


cdef inline _py_ptr_type(void *ptr):
    return _py_type(cowl_get_type(ptr))


cdef inline CowlObjectType _cowl_type(t):
    return <CowlObjectType>_TYPES_R[t]


cdef inline CowlAxiomType _cowl_axiom_type(t):
    return <CowlAxiomType>(_cowl_type(t) - CowlObjectType.COWL_OT_FIRST_A)


cdef inline CowlCharAxiomType _cowl_char_axiom_type(t):
    return <CowlCharAxiomType>(_cowl_type(t) - CowlObjectType.COWL_OT_A_FUNC_OBJ_PROP)


cdef inline CowlPrimitiveType _cowl_primitive_type(t):
    cdef CowlObjectType ot = _cowl_type(t)
    if (ot == CowlObjectType.COWL_OT_CE_CLASS):
        return CowlPrimitiveType.COWL_PT_CLASS
    if (ot == CowlObjectType.COWL_OT_DR_DATATYPE):
        return CowlPrimitiveType.COWL_PT_DATATYPE
    if (ot == CowlObjectType.COWL_OT_OPE_OBJ_PROP):
        return CowlPrimitiveType.COWL_PT_OBJ_PROP
    if (ot == CowlObjectType.COWL_OT_DPE_DATA_PROP):
        return CowlPrimitiveType.COWL_PT_DATA_PROP
    if (ot == CowlObjectType.COWL_OT_ANNOT_PROP):
        return CowlPrimitiveType.COWL_PT_ANNOT_PROP
    if (ot == CowlObjectType.COWL_OT_I_NAMED):
        return CowlPrimitiveType.COWL_PT_NAMED_IND
    if (ot == CowlObjectType.COWL_OT_I_ANONYMOUS):
        return CowlPrimitiveType.COWL_PT_ANON_IND
    return CowlPrimitiveType.COWL_PT_IRI


# C helpers


cdef class Ptr:
    cdef void *p

    @staticmethod
    cdef Ptr wrap(void *ptr):
        if not ptr:
            return NULLPtr
        cdef Ptr obj = Ptr.__new__(Ptr)
        obj.p = ptr
        return obj

    @staticmethod
    cdef Ptr to(Object obj):
        return NULLPtr if obj is None else Ptr.wrap(cowl_retain(obj.ptr))

    def __dealloc__(self) -> None:
        if self.p:
            cowl_release(self.p)


cdef Ptr NULLPtr = Ptr.__new__(Ptr)


cdef Exception as_exception(cowl_ret code, str msg = None):
    cdef UString str = cowl_ret_to_string(code)
    if not msg:
        msg = ustring_to_str(&str, deinit=False).capitalize()
    if code == Ret.ERR_MEM:
        return MemoryError(msg)
    if code == Ret.ERR_BOUNDS:
        return IndexError(msg)
    if code == Ret.ERR_IO:
        return OSError(f"{msg}: {os.strerror(errno)}" if errno != 0 else msg)
    if code == Ret.ERR_SYNTAX:
        return SyntaxError(msg)
    return RuntimeError(msg)


cdef str cowl_error_to_str(const CowlError *error):
    cdef UString str = cowl_error_to_string(error)
    return ustring_to_str(&str).capitalize()


cdef inline UString ustring_wrap_bytes(bytes data):
    return ustring_wrap(<const char *>data, len(data))


cdef inline UString ustring_copy_bytes(bytes data):
    return ustring_copy(<const char *>data, len(data))


cdef inline UString ustring_copy_str(str pystr):
    return ustring_copy_bytes(pystr.encode())


cdef str ustring_to_str(UString *ustr, bool deinit = True):
    cdef UString val = ustr[0]
    try:
        ret: str = ustring_data(val)[:ustring_length(val)].decode()
    finally:
        if deinit:
            ustring_deinit(ustr)
    return ret


cdef str ustrbuf_to_str(UStrBuf *buf, bool deinit = True):
    try:
        ret: str = ustrbuf_data(buf)[:ustrbuf_length(buf)].decode()
    finally:
        if deinit:
            ustrbuf_deinit(buf)
    return ret


cdef ulib_ret pystream_read(void *ctx, void *buffer, size_t size, size_t *read) noexcept:
    try:
        stream: IOBase = <object>ctx
        data = stream.read(size)
        if data is None:
            return Ret.ERR_IO
        read[0] = len(data)
        memcpy(buffer, <char *>data, read[0])
        return Ret.OK
    except Exception:
        return Ret.ERR_IO


cdef ulib_ret pystream_write(void *ctx, const void *buffer, size_t size, size_t *written) noexcept:
    cdef char[:] memview
    try:
        stream: IOBase = <object>ctx
        memview = <char[:size]>buffer
        written[0] = stream.write(memview)
        return Ret.OK
    except Exception:
        return Ret.ERR_IO


cdef ulib_ret pystream_reset(void *ctx) noexcept:
    try:
        stream: IOBase = <object>ctx
        stream.seek(0)
        return Ret.OK
    except Exception:
        return Ret.ERR_IO


cdef ulib_ret pystream_flush(void *ctx) noexcept:
    try:
        stream: IOBase = <object>ctx
        stream.flush()
        return Ret.OK
    except Exception:
        return Ret.ERR_IO


cdef ulib_ret pystream_free(void *ctx) noexcept:
    Py_DECREF(<object>ctx)
    return Ret.OK


cdef UIStream uistream_from_py(src: IOBase | Path | str):
    if isinstance(src, IOBase):
        Py_INCREF(src)
        return uistream(<void *>src, pystream_read, pystream_reset, pystream_free)
    cdest = _as_bytes(src)
    cdef UIStream stream
    cdef ulib_ret ret = uistream_from_path(&stream, <const char *>cdest)
    if cowl_is_err(ret):
        raise as_exception(ret)
    return stream


cdef UOStream uostream_from_py(dst: IOBase | Path | str):
    if isinstance(dst, IOBase):
        Py_INCREF(dst)
        return uostream(<void *>dst, pystream_write, NULL, pystream_reset, pystream_flush, pystream_free)
    cdest = _as_bytes(dst)
    cdef UOStream stream
    cdef ulib_ret ret
    if cowl_is_err(ret := uostream_to_path(&stream, <const char *>cdest)):
        raise as_exception(ret)
    if cowl_is_err(ret := uostream_buf(&stream, 16384)):
        raise as_exception(ret)
    return stream


cdef CowlString *cowl_string_from_str_raw(str s):
    return cowl_string(ustring_copy_str(s))


cdef Ptr cowl_string_from_str(str s):
    return Ptr.wrap(cowl_string_from_str_raw(s))


cdef str cowl_string_to_str(CowlString *s):
    return ustring_to_str(<UString *>cowl_string_get_raw(s), deinit=False)


cdef CowlVector *cowl_vector_from_py_raw(items: Iterable[Object] | None):
    if items is None:
        return NULL

    if isinstance(items, Collection):
        return <CowlVector *>cowl_retain((<Collection>items).ptr)

    cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
    cdef CowlObject *ptr
    for item in items:
        ptr = <CowlObject *>(<Object?>item).ptr
        uvec_push_CowlObjectPtr(&vec, ptr)
        cowl_retain(ptr)
    return cowl_vector_wrap(&vec)


cdef Ptr cowl_vector_from_py(items: Iterable[Object] | None):
    return Ptr.wrap(cowl_vector_from_py_raw(items))


cdef cowl_ret _foreach_cb(void *func, CowlAny *obj) noexcept:
    try:
        (<object>func)(Object.retain(obj))
    except StopIteration:
         return Ret.NO
    except Exception:
        return Ret.ERR
    return Ret.OK


cdef inline CowlIterator cowl_iterator_from_py(func: Callable[[Object], None]):
    cdef CowlIterator iter
    iter.ctx = <void *>func
    iter.for_each = _foreach_cb
    return iter


cdef inline CowlAxiomFlags cowl_axiom_flags_from_py(types: Types | None):
    if not types:
        return COWL_AF_ALL

    cdef CowlAxiomFlags flags = COWL_AF_NONE
    for t in _as_tuple(types):
        flags = cowl_axiom_flags_add_type(flags, _cowl_axiom_type(t))
    return flags


cdef inline CowlPrimitiveFlags cowl_primitive_flags_from_py(types: Types | None):
    if not types:
        return COWL_PF_ALL

    cdef CowlPrimitiveFlags flags = COWL_PF_NONE
    for t in _as_tuple(types):
        if t is Entity:
            flags |= COWL_PF_ENTITY
        elif t is Individual:
            flags |= COWL_PF_IND
        elif t is Property:
            flags |= COWL_PF_PROP
        else:
            flags = cowl_primitive_flags_add_type(flags, _cowl_primitive_type(t))
    return flags


cdef inline CowlAxiomFilter cowl_axiom_filter_from_py(
    types: Types[Axiom] | None,
    primitives: OneOrMany | None,
):
    cdef CowlAxiomFilter filter = cowl_axiom_filter(cowl_axiom_flags_from_py(types))
    for p in _as_iterable(primitives):
        cowl_axiom_filter_add_primitive(&filter, (<Object>p).ptr)
    return filter


# Utilities


def intersection_of(*args: ClassExpression | DataRange) -> ObjectIntersectionOf | DataIntersectionOf:
    if isinstance(args[0], ClassExpression):
        return ObjectIntersectionOf(*(op for arg in args for op in ObjectIntersectionOf.as_operands(arg)))
    return DataIntersectionOf(*(op for arg in args for op in DataIntersectionOf.as_operands(arg)))


def union_of(*args: ClassExpression | DataRange) -> ObjectUnionOf | DataUnionOf:
    if isinstance(args[0], ClassExpression):
        return ObjectUnionOf(*(op for arg in args for op in ObjectUnionOf.as_operands(arg)))
    return DataUnionOf(*(op for arg in args for op in DataUnionOf.as_operands(arg)))


def one_of(*args: Individual | Literal | LiteralValue) -> ObjectOneOf | DataOneOf:
    if isinstance(args[0], Individual):
        return ObjectOneOf(*args)
    return DataOneOf(*(_as_literal(v) for v in args))


def all_equivalent(
    *args: ClassExpression | ObjectPropertyExpression | DataProperty,
) -> EquivalentClasses | EquivalentObjectProperties | EquivalentDataProperties:
    if isinstance(args[0], ClassExpression):
        return EquivalentClasses(*args)
    if isinstance(args[0], ObjectPropertyExpression):
        return EquivalentObjectProperties(*args)
    return EquivalentDataProperties(*args)


def all_disjoint(
    *args: ClassExpression | ObjectPropertyExpression | DataProperty,
) -> DisjointClasses | DisjointObjectProperties | DisjointDataProperties:
    if isinstance(args[0], ClassExpression):
        return DisjointClasses(*args)
    if isinstance(args[0], ObjectPropertyExpression):
        return DisjointObjectProperties(*args)
    return DisjointDataProperties(*args)


def all_same(*args: Individual) -> SameIndividual:
    return SameIndividual(*args)


def all_different(*args: Individual) -> DifferentIndividuals:
    return DifferentIndividuals(*args)


def chain(*args: ObjectPropertyExpression) -> ObjectPropertyChain:
    return ObjectPropertyChain(*args)


def is_entity(obj: Object) -> bool:
    return obj.is_entity()


def is_primitive(obj: Object) -> bool:
    return obj.is_primitive()


def is_axiom(obj: Object) -> bool:
    return obj.is_axiom()


def is_class_expression(obj: Object) -> bool:
    return obj.is_class_expression()


def is_data_range(obj: Object) -> bool:
    return obj.is_data_range()


def is_object_property_expression(obj: Object) -> bool:
    return obj.is_object_property_expression()


def is_data_property_expression(obj: Object) -> bool:
    return obj.is_data_property_expression()


def is_individual(obj: Object) -> bool:
    return obj.is_individual()


cdef inline Literal _as_literal(val: Literal | LiteralValue, dt: Datatype | None = None):
    return val if isinstance(val, Literal) else Literal(val, dt)


cdef inline IRI _as_iri(val: IRI | str):
    return val if isinstance(val, IRI) else IRI(val)


cdef inline str _as_str(val):
    return val if isinstance(val, str) else str(val)


cdef inline bytes _as_bytes(val):
    return _as_str(val).encode()


cdef inline _as_iterable(val):
    return val if isinstance(val, Iterable) else (val,)


cdef inline tuple _as_tuple(val):
    if isinstance(val, tuple):
        return val
    if isinstance(val, Iterable):
        return tuple(val)
    return (val,)


# Enums


class Position(IntFlag):
    LEFT = COWL_PS_LEFT
    RIGHT = COWL_PS_RIGHT
    MIDDLE = COWL_PS_MIDDLE
    ANY = COWL_PS_ANY
    SUBJECT = COWL_PS_SUBJECT
    PREDICATE = COWL_PS_PREDICATE
    OBJECT = COWL_PS_OBJECT
    VALUE = COWL_PS_OBJECT


# Base types


cdef class Object:
    cdef void *ptr

    @staticmethod
    cdef Object wrap_as(ptype: type[Object], void *ptr):
        cdef Object obj = ptype.__new__(ptype)
        obj.ptr = ptr
        return obj

    @staticmethod
    cdef Object retain_as(ptype: type[Object], void *ptr):
        return Object.wrap_as(ptype, cowl_retain(ptr))

    @staticmethod
    cdef Object wrap(void *ptr):
        return Object.wrap_as(_py_ptr_type(ptr), ptr)

    @staticmethod
    cdef Object retain(void *ptr):
        return Object.wrap_as(_py_ptr_type(ptr), cowl_retain(ptr))

    def __cinit__(self):
        self.ptr = NULL

    def __init__(self) -> NoReturn:
        raise RuntimeError("Object cannot be instantiated directly")

    def __dealloc__(self):
        if self.ptr:
            cowl_release(self.ptr)

    def __str__(self) -> str:
        cdef UString str_rep = cowl_to_string(self.ptr)
        return ustring_to_str(&str_rep)

    def __repr__(self) -> str:
        cdef UString str_rep = cowl_to_debug_string(self.ptr)
        return ustring_to_str(&str_rep)

    def __eq__(self, other: Object) -> bool:
        return cowl_equals(self.ptr, other.ptr)

    def __hash__(self) -> int:
        return hash(cowl_hash(self.ptr))

    cpdef bool is_primitive(self):
        return cowl_is_primitive(self.ptr)

    cpdef bool is_entity(self):
        return cowl_is_entity(self.ptr)

    cpdef bool is_axiom(self):
        return cowl_is_axiom(self.ptr)

    cpdef bool is_class_expression(self):
        return cowl_is_cls_exp(self.ptr)

    cpdef bool is_data_range(self):
        return cowl_is_data_range(self.ptr)

    cpdef bool is_object_property_expression(self):
        return cowl_is_obj_prop_exp(self.ptr)

    cpdef bool is_data_property_expression(self):
        return cowl_is_data_prop_exp(self.ptr)

    cpdef bool is_individual(self):
        return cowl_is_individual(self.ptr)

    cpdef bool is_reserved(self):
        return cowl_is_reserved(self.ptr)


class Annotated:
    __slots__ = ()

    def annotations(self: Object) -> Collection[Annotation]:
        cdef void *annot_ptr = cowl_get_annot(self.ptr)
        return Object.retain(annot_ptr) if annot_ptr else Collection()


class HasIRI:
    __slots__ = ()

    def iri(self: Object) -> IRI:
        cdef void *iri_ptr = cowl_get_iri(self.ptr)

        if not iri_ptr:
            raise TypeError("Object does not have an IRI")

        return Object.retain(iri_ptr)

    def namespace(self: Object) -> str:
        cdef CowlString *ns_ptr = cowl_get_ns(self.ptr)

        if not ns_ptr:
            raise TypeError("Object does not have a namespace")

        return cowl_string_to_str(ns_ptr)

    def remainder(self: Object) -> str:
        cdef CowlString *rem_ptr = cowl_get_rem(self.ptr)

        if rem_ptr == NULL:
            raise TypeError("Object does not have a remainder")

        return cowl_string_to_str(rem_ptr)


cdef void _foreach_primitive(Object obj, CowlIterator *iter, types: Types | None):
    cowl_iterate_primitives(obj.ptr, cowl_primitive_flags_from_py(types), iter)


class HasPrimitives:
    __slots__ = ()

    def has_primitive(self: Object, primitive: Object) -> bool:
        return cowl_has_primitive(self.ptr, primitive.ptr)

    def foreach_primitive(
        self: Object,
        func: Callable[[Primitive], None],
        types: Types | None = None,
    ) -> None:
        cdef CowlIterator iter = cowl_iterator_from_py(func)
        _foreach_primitive(self, &iter, types)

    def primitives(
        self: Object,
        types: Types | None = None,
    ) -> Collection[Primitive]:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, True)
        _foreach_primitive(self, &iter, types)
        return Object.wrap(cowl_vector_wrap(&vec))


class Primitive(HasPrimitives):
    __slots__ = ()


class Entity(Primitive, HasIRI):
    __slots__ = ()

    def declare(self) -> Declaration:
        return Declaration(self)


class Property(Entity):
    __slots__ = ()


cdef class AnnotationProperty(Object, Property):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        self.ptr = cowl_annot_prop(<CowlIRI *>iri_obj.ptr)

    def __call__(
        self,
        subject: AnnotationSubject | HasIRI | AnnotationValue | LiteralValue,
        value: AnnotationValue | LiteralValue | None = None, \
    ) -> AnnotationAssertion:
        if value is None:
            value = subject
            subject = None
        if not (isinstance(value, Object) and value.is_primitive()):
            value = _as_literal(value)
        if subject is None:
            return Annotation(self, value)
        if not subject.is_individual():
            subject = subject.iri()
        return AnnotationAssertion(self, subject, value)

    def is_subproperty_of(self, parent: AnnotationProperty) -> SubAnnotationPropertyOf:
        return SubAnnotationPropertyOf(self, parent)

    def has_domain(self, domain: IRI) -> AnnotationPropertyDomain:
        return AnnotationPropertyDomain(self, domain)

    def has_range(self, range_: IRI) -> AnnotationPropertyRange:
        return AnnotationPropertyRange(self, range_)


cdef class Annotation(Object, Annotated, HasPrimitives):

    def __init__(
        self,
        property_: AnnotationProperty,
        value: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_annotation(<CowlAnnotProp *>property_.ptr, value.ptr, <CowlVector *>annot.p)

    def property_(self) -> AnnotationProperty:
        return Object.retain(cowl_annotation_get_prop(<CowlAnnotation *>self.ptr))

    def value(self) -> Object:
        return Object.retain(cowl_annotation_get_value(<CowlAnnotation *>self.ptr))


cdef class Collection(Object, HasPrimitives, ABCCollection):

    def __init__(self, *args: Object) -> None:
        self.ptr = cowl_vector_from_py_raw(args)

    def __len__(self) -> int:
        return cowl_vector_count(<CowlVector *>self.ptr)

    def __contains__(self, item: Object) -> bool:
        return cowl_vector_contains(<CowlVector *>self.ptr, item.ptr)

    def __iter__(self) -> Iterator[Object]:
        cdef CowlVector *vec = <CowlVector *>self.ptr
        cdef int count = cowl_vector_count(vec)
        cdef int i
        for i in range(count):
            yield Object.retain(cowl_vector_get_item(vec, i))


cdef class IRI(Object, Primitive, HasIRI):

    def __init__(self, prefix: str, suffix: str | None = None) -> None:
        self.ptr = _iri_from_prefix_suffix(prefix, suffix) if suffix else _iri_from_str(prefix)

    def __call__(self, value: Literal | LiteralValue, dt: Datatype | None = None) -> FacetRestriction:
        return FacetRestriction(self, _as_literal(value, dt))

    def iri(self) -> IRI:
        return self

    def namespace(self) -> str:
        return cowl_string_to_str(cowl_iri_get_ns(<CowlIRI *>self.ptr))

    def remainder(self) -> str:
        return cowl_string_to_str(cowl_iri_get_rem(<CowlIRI *>self.ptr))

    def as_string(self) -> str:
        cdef UString iri_str = cowl_iri_to_string(<CowlIRI *>self.ptr)
        return ustring_to_str(&iri_str)


cdef inline void *_iri_from_str(str s):
    byte_str = s.encode()
    return cowl_iri_from_string(ustring_wrap_bytes(byte_str))


cdef inline void *_iri_from_prefix_suffix(str prefix, str suffix):
    cdef Ptr p_ptr = cowl_string_from_str(prefix)
    cdef Ptr s_ptr = cowl_string_from_str(suffix)
    return cowl_iri(<CowlString *>p_ptr.p, <CowlString *>s_ptr.p)


cdef class Literal(Object, HasPrimitives):
    def __init__(
        self,
        value: LiteralValue,
        datatype: Datatype | None = None,
        language: str | None = None,
    ) -> None:
        cdef Ptr c_value
        cdef Ptr c_dt_or_lang

        if language:
            value = _as_str(value)
            c_dt_or_lang = cowl_string_from_str(language)
        else:
            value, datatype = _dt_value_from_py(value, datatype)
            c_dt_or_lang = Ptr.to(datatype)

        c_value = cowl_string_from_str(value)
        self.ptr = cowl_literal(<CowlString *>c_value.p, <CowlAny *>c_dt_or_lang.p)

    def datatype(self) -> Datatype:
        return Object.retain(cowl_literal_get_datatype(<CowlLiteral *>self.ptr))

    def value(self) -> str:
        return cowl_string_to_str(cowl_literal_get_value(<CowlLiteral *>self.ptr))

    def language(self) -> str | None:
        cdef CowlString *c_str = cowl_literal_get_lang(<CowlLiteral *>self.ptr)
        return cowl_string_to_str(c_str) if c_str else None


def _dt_value_from_py(val: object, dt: Datatype | None) -> tuple[str, Datatype | None]:
    if isinstance(val, str):
        inferred_dt = XSD.string
    elif isinstance(val, bool):
        inferred_dt = XSD.boolean
        val = "true" if val else "false"
    elif isinstance(val, int):
        inferred_dt = XSD.integer
    elif isinstance(val, float):
        inferred_dt = XSD.double
    elif isinstance(val, date | datetime):
        if not isinstance(val, datetime):  # Check reversed as datetime is a subclass of date.
            val = datetime(val.year, val.month, val.day)
        inferred_dt = XSD.date_time if val.tzinfo is None else XSD.date_time_stamp
        val = val.isoformat()
    else:
        inferred_dt = None
    return _as_str(val), dt or inferred_dt


# Class expressions


cdef class ClassExpression(Object, HasPrimitives):
    def __call__(self, arg: ClassExpression | Individual) -> SubClassOf | ClassAssertion:
        return ClassAssertion(self, arg) if arg.is_individual() else SubClassOf(self, arg)

    def __and__(self, other: ClassExpression) -> ObjectIntersectionOf:
        return ObjectIntersectionOf(
            *ObjectIntersectionOf.as_operands(self),
            *ObjectIntersectionOf.as_operands(other)
        )

    def __or__(self, other: ClassExpression) -> ObjectUnionOf:
        return ObjectUnionOf(
            *ObjectUnionOf.as_operands(self),
            *ObjectUnionOf.as_operands(other)
        )

    def __invert__(self) -> ClassExpression:
        return self.operand() if isinstance(self, ObjectComplementOf) else ObjectComplementOf(self)

    def that(self, *args: ClassExpression) -> ObjectIntersectionOf:
        return ObjectIntersectionOf(
            *ObjectIntersectionOf.as_operands(self),
            *(op for arg in args for op in ObjectIntersectionOf.as_operands(arg))
        )

    def is_a(self, parent: ClassExpression) -> SubClassOf:
        return SubClassOf(self, parent)

    def is_subclass_of(self, parent: ClassExpression) -> SubClassOf:
        return SubClassOf(self, parent)

    def is_same_as(self, *args: ClassExpression) -> EquivalentClasses:
        return EquivalentClasses(self, *args)

    def is_equivalent_to(self, *args: ClassExpression) -> EquivalentClasses:
        return EquivalentClasses(self, *args)

    def is_not_a(self, other: ClassExpression) -> DisjointClasses:
        return DisjointClasses(self, other)

    def is_disjoint_with(self, *args: ClassExpression) -> DisjointClasses:
        return DisjointClasses(self, *args)

    def has_key(self, *args: ObjectPropertyExpression | DataProperty) -> HasKey:
        obj_props = (p for p in args if p.is_object_property_expression())
        data_props = (p for p in args if p.is_data_property_expression())
        return HasKey(self, obj_props, data_props)


cdef class Class(ClassExpression, Entity):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        self.ptr = cowl_class(<CowlIRI *>iri_obj.ptr)

    def is_disjoint_union_of(self, *args: ClassExpression) -> DisjointUnion:
        return DisjointUnion(self, *args)


cdef class NAryClassExpression(ClassExpression):
    def __init__(self, *args: ClassExpression) -> None:
        cdef CowlNAryType ctype = (
            CowlNAryType.COWL_NT_INTERSECT if type(self) is ObjectIntersectionOf
            else CowlNAryType.COWL_NT_UNION
        )
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_nary_bool(ctype, <CowlVector *>vec.p)

    def operands(self) -> Collection:
        return Object.retain(cowl_nary_bool_get_operands(<CowlNAryBool *>self.ptr))


cdef class ObjectIntersectionOf(NAryClassExpression):
    @staticmethod
    def as_operands(cls_exp: ClassExpression) -> Iterable[ClassExpression]:
        if isinstance(cls_exp, ObjectIntersectionOf):
            return cls_exp.operands()
        return (cls_exp,)


cdef class ObjectUnionOf(NAryClassExpression):
    @staticmethod
    def as_operands(cls_exp: ClassExpression) -> Iterable[ClassExpression]:
        if isinstance(cls_exp, ObjectUnionOf):
            return cls_exp.operands()
        return (cls_exp,)


cdef class ObjectComplementOf(ClassExpression):
    def __init__(self, operand: ClassExpression) -> None:
        self.ptr = cowl_obj_compl(operand.ptr)

    def operand(self) -> ClassExpression:
        return Object.retain(cowl_obj_compl_get_operand(<CowlObjCompl *>self.ptr))


cdef class ObjectOneOf(ClassExpression):
    def __init__(self, *args: Individual) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_obj_one_of(<CowlVector *>vec.p)

    def individuals(self) -> Collection[Individual]:
        return Object.retain(cowl_obj_one_of_get_inds(<CowlObjOneOf *>self.ptr))


cdef class ObjectQuantifiedRestriction(ClassExpression):
    def __init__(self, property_: ObjectPropertyExpression, filler: ClassExpression) -> None:
        cdef CowlQuantType ctype = (
            CowlQuantType.COWL_QT_SOME if type(self) is ObjectSomeValuesFrom
            else CowlQuantType.COWL_QT_ALL
        )
        self.ptr = cowl_obj_quant(ctype, (<Object>property_).ptr, (<Object>filler).ptr)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_quant_get_prop(<CowlObjQuant *>self.ptr))

    def filler(self) -> ClassExpression:
        return Object.retain(cowl_obj_quant_get_filler(<CowlObjQuant *>self.ptr))


cdef class ObjectSomeValuesFrom(ObjectQuantifiedRestriction):
    pass


cdef class ObjectAllValuesFrom(ObjectQuantifiedRestriction):
    pass


cdef class ObjectHasSelf(ClassExpression):
    def __init__(self, property_: ObjectPropertyExpression) -> None:
        self.ptr = cowl_obj_has_self(property_.ptr)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_has_self_get_prop(<CowlObjHasSelf *>self.ptr))


cdef class ObjectHasValue(ClassExpression):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        value: Individual,
    ) -> None:
        self.ptr = cowl_obj_has_value(property_.ptr, value.ptr)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_has_value_get_prop(<CowlObjHasValue *>self.ptr))

    def value(self) -> Individual:
        return Object.retain(cowl_obj_has_value_get_value(<CowlObjHasValue *>self.ptr))


cdef class ObjectCardinalityRestriction(ClassExpression):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None
    ) -> None:
        cdef CowlCardType ctype = (
            CowlCardType.COWL_CT_MIN if type(self) is ObjectMinCardinality else
            CowlCardType.COWL_CT_MAX if type(self) is ObjectMaxCardinality else
            CowlCardType.COWL_CT_EXACT
        )
        cdef void *filler_ptr = (<Object>filler).ptr if filler else NULL
        self.ptr = cowl_obj_card(ctype, (<Object>property_).ptr, filler_ptr, cardinality)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_card_get_prop(<CowlObjCard *>self.ptr))

    def cardinality(self) -> int:
        return cowl_obj_card_get_cardinality(<CowlObjCard *>self.ptr)

    def filler(self) -> ClassExpression | None:
        cdef CowlClsExp *filler_ptr = cowl_obj_card_get_filler(<CowlObjCard *>self.ptr)
        return Object.retain(filler_ptr) if filler_ptr else None


cdef class ObjectMinCardinality(ObjectCardinalityRestriction):
    pass


cdef class ObjectMaxCardinality(ObjectCardinalityRestriction):
    pass


cdef class ObjectExactCardinality(ObjectCardinalityRestriction):
    pass


cdef class DataQuantifiedRestriction(ClassExpression):
    def __init__(
        self,
        property_: DataProperty,
        data_range: DataRange
    ) -> None:
        cdef CowlQuantType ctype = (
            CowlQuantType.COWL_QT_SOME if type(self) is DataSomeValuesFrom else
            CowlQuantType.COWL_QT_ALL
        )
        self.ptr = cowl_data_quant(ctype, property_.ptr, data_range.ptr)

    def property_(self) -> DataProperty:
        return Object.retain(cowl_data_quant_get_prop(<CowlDataQuant *>self.ptr))

    def range(self) -> DataRange:
        return Object.retain(cowl_data_quant_get_range(<CowlDataQuant *>self.ptr))


cdef class DataSomeValuesFrom(DataQuantifiedRestriction):
    pass


cdef class DataAllValuesFrom(DataQuantifiedRestriction):
    pass


cdef class DataHasValue(ClassExpression):
    def __init__(
        self,
        property_: DataProperty,
        value: Literal,
    ) -> None:
        self.ptr = cowl_data_has_value(property_.ptr, <CowlLiteral *>value.ptr)

    def property_(self) -> DataProperty:
        return Object.retain(cowl_data_has_value_get_prop(<CowlDataHasValue *>self.ptr))

    def value(self) -> Literal:
        return Object.retain(cowl_data_has_value_get_value(<CowlDataHasValue *>self.ptr))


cdef class DataCardinalityRestriction(ClassExpression):
    def __init__(
        self,
        property_: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None
    ) -> None:
        cdef CowlCardType ctype = (
            CowlCardType.COWL_CT_MIN if type(self) is DataMinCardinality else
            CowlCardType.COWL_CT_MAX if type(self) is DataMaxCardinality else
            CowlCardType.COWL_CT_EXACT
        )
        cdef void *range_ptr = data_range.ptr if data_range else NULL
        self.ptr = cowl_data_card(ctype, property_.ptr, range_ptr, cardinality)

    def property_(self) -> DataProperty:
        return Object.retain(cowl_data_card_get_prop(<CowlDataCard *>self.ptr))

    def cardinality(self) -> int:
        return cowl_data_card_get_cardinality(<CowlDataCard *>self.ptr)

    def filler(self) -> ClassExpression | None:
        cdef CowlDataRange *range = cowl_data_card_get_range(<CowlDataCard *>self.ptr)
        return Object.retain(range) if range else None


cdef class DataMinCardinality(DataCardinalityRestriction):
    pass


cdef class DataMaxCardinality(DataCardinalityRestriction):
    pass


cdef class DataExactCardinality(DataCardinalityRestriction):
    pass


# Data ranges


cdef class DataRange(Object, HasPrimitives):
    def __and__(self, other: DataRange) -> DataIntersectionOf:
        return DataIntersectionOf(
            *DataIntersectionOf.as_operands(self),
            *DataIntersectionOf.as_operands(other)
        )

    def __or__(self, other: DataRange) -> DataUnionOf:
        return DataUnionOf(
            *DataUnionOf.as_operands(self),
            *DataUnionOf.as_operands(other)
        )

    def __invert__(self) -> DataRange:
        return self.operand() if isinstance(self, DataComplementOf) else DataComplementOf(self)

    def that(self, *args: DataRange) -> DataIntersectionOf:
        return DataIntersectionOf(
            *DataIntersectionOf.as_operands(self),
            *(op for arg in args for op in DataIntersectionOf.as_operands(arg))
        )


cdef class Datatype(DataRange, Entity):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        self.ptr = cowl_datatype(<CowlIRI *>iri_obj.ptr)

    def __call__(self, value: LiteralValue) -> Literal:
        return Literal(value, self)

    def __getitem__(self, item: FacetRestriction) -> DatatypeRestriction:
        return DatatypeRestriction(self, item)

    def __hash__(self) -> int:
        return super().__hash__()

    def __eq__(self, other: Object) -> bool:
        return super().__eq__(other)

    def __le__(self, val: LiteralValue) -> DatatypeRestriction:
        return DatatypeRestriction(self, XSD.max_inclusive(val, self))

    def __lt__(self, val: LiteralValue) -> DatatypeRestriction:
        return DatatypeRestriction(self, XSD.max_exclusive(val, self))

    def __ge__(self, val: LiteralValue) -> DatatypeRestriction:
        return DatatypeRestriction(self, XSD.min_inclusive(val, self))

    def __gt__(self, val: LiteralValue) -> DatatypeRestriction:
        return DatatypeRestriction(self, XSD.min_exclusive(val, self))

    def is_defined_as(self, data_range: DataRange) -> DatatypeDefinition:
        return DatatypeDefinition(self, data_range)

    def that_has(
        self,
        *args: FacetRestriction,
        **kw: Literal | LiteralValue | None,
    ) -> DatatypeRestriction:
        return DatatypeRestriction(self, *args, *(
            f[0](v, f[1] or self) for k, v in kw.items()
            if v is not None and (f := _FACETS.get(k))
        ))


cdef class NAryDataRange(DataRange):
    def __init__(self, *args: DataRange) -> None:
        cdef CowlNAryType ctype = (
            CowlNAryType.COWL_NT_INTERSECT if type(self) is DataIntersectionOf
            else CowlNAryType.COWL_NT_UNION
        )
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_nary_data(ctype, <CowlVector *>vec.p)

    def operands(self) -> Collection[DataRange]:
        return Object.retain(cowl_nary_data_get_operands(<CowlNAryData *>self.ptr))


cdef class DataIntersectionOf(NAryDataRange):
    @staticmethod
    def as_operands(data_range: DataRange) -> Iterable[DataRange]:
        if isinstance(data_range, DataIntersectionOf):
            return data_range.operands()
        return (data_range,)


cdef class DataUnionOf(NAryDataRange):
    @staticmethod
    def as_operands(data_range: DataRange) -> Iterable[DataRange]:
        if isinstance(data_range, DataUnionOf):
            return data_range.operands()
        return (data_range,)

cdef class DataComplementOf(DataRange):
    def __init__(self, operand: DataRange) -> None:
        self.ptr = cowl_data_compl(operand.ptr)

    def operand(self) -> DataRange:
        return Object.retain(cowl_data_compl_get_operand(<CowlDataCompl *>self.ptr))


cdef class DataOneOf(DataRange):
    def __init__(self, *args: Literal) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_data_one_of(<CowlVector *>vec.p)

    def values(self) -> Collection[Literal]:
        return Object.retain(cowl_data_one_of_get_values(<CowlDataOneOf *>self.ptr))


cdef class FacetRestriction(Object):
    def __init__(
        self,
        facet: IRI,
        value: Literal,
    ) -> None:
        self.ptr = cowl_facet_restr(<CowlIRI *>facet.ptr, <CowlLiteral *>value.ptr)

    def facet(self) -> IRI:
        return Object.retain(cowl_facet_restr_get_facet(<CowlFacetRestr *>self.ptr))

    def value(self) -> Literal:
        return Object.retain(cowl_facet_restr_get_value(<CowlFacetRestr *>self.ptr))


cdef class DatatypeRestriction(DataRange):
    def __init__(
        self,
        datatype: Datatype,
        *args: FacetRestriction,
    ) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_datatype_restr(<CowlDatatype *>datatype.ptr, <CowlVector *>vec.p)

    def __getitem__(self, item: FacetRestriction) -> DatatypeRestriction:
        return DatatypeRestriction(self.datatype(), *self.restrictions(), item)

    def __hash__(self) -> int:
        return super().__hash__()

    def __eq__(self, other: Object) -> bool:
        return super().__eq__(other)

    def __le__(self, val: LiteralValue) -> DatatypeRestriction:
        dt = self.datatype()
        return DatatypeRestriction(dt, *self.restrictions(), XSD.max_inclusive(val, dt))

    def __lt__(self, val: LiteralValue) -> DatatypeRestriction:
        dt = self.datatype()
        return DatatypeRestriction(dt, *self.restrictions(), XSD.max_exclusive(val, dt))

    def __ge__(self, val: LiteralValue) -> DatatypeRestriction:
        dt = self.datatype()
        return DatatypeRestriction(dt, *self.restrictions(), XSD.min_inclusive(val, dt))

    def __gt__(self, val: LiteralValue) -> DatatypeRestriction:
        dt = self.datatype()
        return DatatypeRestriction(dt, *self.restrictions(), XSD.min_exclusive(val, dt))

    def datatype(self) -> Datatype:
        return Object.retain(cowl_datatype_restr_get_datatype(<CowlDatatypeRestr *>self.ptr))

    def restrictions(self) -> Collection[FacetRestriction]:
        return Object.retain(cowl_datatype_restr_get_restrictions(<CowlDatatypeRestr *>self.ptr))

    def that_has(
        self,
        *args: FacetRestriction,
        **kwargs: Literal | LiteralValue | None,
    ) -> DatatypeRestriction:
        return self.datatype().that_has(*self.restrictions(), *args, **kwargs)


# Individuals


cdef class Individual(Object, Primitive):
    def is_a(self, class_: ClassExpression) -> ClassAssertion:
        return ClassAssertion(class_, self)

    def is_same_as(self, *args: Individual) -> SameIndividual:
        return SameIndividual(self, *args)

    def is_different_from(self, *args: Individual) -> DifferentIndividuals:
        return DifferentIndividuals(self, *args)


cdef class NamedIndividual(Individual, Entity):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        self.ptr = cowl_named_ind(<CowlIRI *>iri_obj.ptr)


cdef class AnonymousIndividual(Individual):
    def __init__(self, node_id: str | None = None) -> None:
        cdef Ptr c_str = cowl_string_from_str(node_id) if node_id else NULLPtr
        self.ptr = cowl_anon_ind(<CowlString *>c_str.p)


# Object peoperty expressions


cdef class ObjectPropertyExpression(Object, HasPrimitives):
    def __call__(self, subject: Individual, object_: Individual) -> ObjectPropertyAssertion:
        return ObjectPropertyAssertion(self, subject, object_)

    def some(self, filler: ClassExpression) -> ObjectSomeValuesFrom:
        return ObjectSomeValuesFrom(self, filler)

    def only(self, filler: ClassExpression) -> ObjectAllValuesFrom:
        return ObjectAllValuesFrom(self, filler)

    def has_value(self, value: Individual) -> ObjectHasValue:
        return ObjectHasValue(self, value)

    def has_self(self) -> ObjectHasSelf:
        return ObjectHasSelf(self)

    def min(self, cardinality: int, filler: ClassExpression | None = None) -> ObjectMinCardinality:
        return ObjectMinCardinality(self, cardinality, filler)

    def max(self, cardinality: int, filler: ClassExpression | None = None) -> ObjectMaxCardinality:
        return ObjectMaxCardinality(self, cardinality, filler)

    def exactly(self, cardinality: int, filler: ClassExpression | None = None) -> ObjectExactCardinality:
        return ObjectExactCardinality(self, cardinality, filler)

    def is_subproperty_of(self, parent: ObjectPropertyExpression) -> SubObjectPropertyOf:
        return SubObjectPropertyOf(self, parent)

    def is_equivalent_to(self, *args: ObjectPropertyExpression) -> EquivalentObjectProperties:
        return EquivalentObjectProperties(self, *args)

    def is_disjoint_with(self, *args: ObjectPropertyExpression) -> DisjointObjectProperties:
        return DisjointObjectProperties(self, *args)

    def is_inverse_of(self, other: ObjectPropertyExpression) -> InverseObjectProperties:
        return InverseObjectProperties(self, other)

    def has_domain(self, domain: ClassExpression) -> ObjectPropertyDomain:
        return ObjectPropertyDomain(self, domain)

    def has_range(self, property_range: ClassExpression) -> ObjectPropertyRange:
        return ObjectPropertyRange(self, property_range)

    def is_functional(self) -> FunctionalObjectProperty:
        return FunctionalObjectProperty(self)

    def is_inverse_functional(self) -> InverseFunctionalObjectProperty:
        return InverseFunctionalObjectProperty(self)

    def is_symmetric(self) -> SymmetricObjectProperty:
        return SymmetricObjectProperty(self)

    def is_asymmetric(self) -> AsymmetricObjectProperty:
        return AsymmetricObjectProperty(self)

    def is_reflexive(self) -> ReflexiveObjectProperty:
        return ReflexiveObjectProperty(self)

    def is_irreflexive(self) -> IrreflexiveObjectProperty:
        return IrreflexiveObjectProperty(self)

    def is_transitive(self) -> TransitiveObjectProperty:
        return TransitiveObjectProperty(self)


cdef class ObjectProperty(ObjectPropertyExpression, Property):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        self.ptr = cowl_obj_prop(<CowlIRI *>iri_obj.ptr)

    def __invert__(self) -> InverseObjectProperty:
        return InverseObjectProperty(self)


cdef class InverseObjectProperty(ObjectPropertyExpression):
    def __init__(self, property_: ObjectProperty) -> None:
        self.ptr = cowl_inv_obj_prop(<CowlObjProp *>property_.ptr)

    def __invert__(self) -> ObjectProperty:
        return self.property_()

    def property_(self) -> ObjectProperty:
        return Object.retain(cowl_inv_obj_prop_get_prop(<CowlInvObjProp *>self.ptr))


cdef class ObjectPropertyChain(Collection):
    def is_subproperty_of(self, parent: ObjectPropertyExpression) -> SubObjectPropertyOf:
        return SubObjectPropertyOf(self, parent)


# Data property expressions


cdef class DataProperty(Object, Property):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        self.ptr = cowl_data_prop(<CowlIRI *>iri_obj.ptr)

    def __call__(self, subj: Individual, value: Literal | LiteralValue) -> DataPropertyAssertion:
        return DataPropertyAssertion(self, subj, _as_literal(value))

    def some(self, data_range: DataRange) -> DataSomeValuesFrom:
        return DataSomeValuesFrom(self, data_range)

    def only(self, data_range: DataRange) -> DataAllValuesFrom:
        return DataAllValuesFrom(self, data_range)

    def has_value(self, value: Literal | LiteralValue) -> DataHasValue:
        return DataHasValue(self, _as_literal(value))

    def min(self, cardinality: int, data_range: DataRange | None = None) -> DataMinCardinality:
        return DataMinCardinality(self, cardinality, data_range)

    def max(self, cardinality: int, data_range: DataRange | None = None) -> DataMaxCardinality:
        return DataMaxCardinality(self, cardinality, data_range)

    def exactly(self, cardinality: int, data_range: DataRange | None = None) -> DataExactCardinality:
        return DataExactCardinality(self, cardinality, data_range)

    def is_subproperty_of(self, parent: DataProperty) -> SubDataPropertyOf:
        return SubDataPropertyOf(self, parent)

    def is_equivalent_to(self, *args: DataProperty) -> EquivalentDataProperties:
        return EquivalentDataProperties(self, *args)

    def is_disjoint_with(self, *args: DataProperty) -> DisjointDataProperties:
        return DisjointDataProperties(self, *args)

    def has_domain(self, domain: ClassExpression) -> DataPropertyDomain:
        return DataPropertyDomain(self, domain)

    def has_range(self, property_range: DataRange) -> DataPropertyRange:
        return DataPropertyRange(self, property_range)

    def is_functional(self) -> FunctionalDataProperty:
        return FunctionalDataProperty(self)


# Axioms


cdef class Axiom(Object, Annotated, HasPrimitives):
    pass


cdef class Declaration(Axiom):
    def __init__(
        self,
        entity: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_decl_axiom(entity.ptr, <CowlVector *>annot.p)

    def entity(self) -> Object:
        return Object.retain(cowl_decl_axiom_get_entity(<CowlDeclAxiom *>self.ptr))


cdef class SubClassOf(Axiom):
    def __init__(
        self,
        child: ClassExpression,
        parent: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_sub_cls_axiom(child.ptr, parent.ptr, <CowlVector *>annot.p)

    def child(self) -> ClassExpression:
        return Object.retain(cowl_sub_cls_axiom_get_sub(<CowlSubClsAxiom *>self.ptr))

    def parent(self) -> ClassExpression:
        return Object.retain(cowl_sub_cls_axiom_get_super(<CowlSubClsAxiom *>self.ptr))


cdef class _NAryClassAxiom(Axiom):
    def __init__(
        self,
        *args: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlNAryAxiomType ctype = (
             CowlNAryAxiomType.COWL_NAT_EQUIV if type(self) is EquivalentClasses
             else CowlNAryAxiomType.COWL_NAT_DISJ
        )
        cdef Ptr vec = cowl_vector_from_py(args)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_nary_cls_axiom(ctype, <CowlVector *>vec.p, <CowlVector *>annot.p)

    def classes(self) -> Collection[ClassExpression]:
        return Object.retain(cowl_nary_cls_axiom_get_classes(<CowlNAryClsAxiom *>self.ptr))


cdef class EquivalentClasses(_NAryClassAxiom):
    pass


cdef class DisjointClasses(_NAryClassAxiom):
    pass


cdef class DisjointUnion(Axiom):
    def __init__(
        self,
        class_: Class,
        *args: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_disj_union_axiom(<CowlClass *>class_.ptr, <CowlVector *>vec.p, <CowlVector *>annot.p)

    def class_(self) -> Class:
        return Object.retain(cowl_disj_union_axiom_get_class(<CowlDisjUnionAxiom *>self.ptr))

    def disjoints(self) -> Collection[ClassExpression]:
        return Object.retain(cowl_disj_union_axiom_get_disjoints(<CowlDisjUnionAxiom *>self.ptr))


cdef class SubObjectPropertyOf(Axiom):
    def __init__(
        self,
        child: ObjectPropertyExpression | Iterable[ObjectPropertyExpression],
        parent: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        cdef Ptr prop_vec
        if child.is_object_property_expression():
            self.ptr = cowl_sub_obj_prop_axiom((<ObjectPropertyExpression>child).ptr,
                                               parent.ptr, <CowlVector *>annot.p)
        else:
            prop_vec = cowl_vector_from_py(child)
            self.ptr = cowl_sub_obj_prop_axiom(<CowlVector *>prop_vec.p, parent.ptr,
                                               <CowlVector *>annot.p)

    def child(self) -> ObjectPropertyExpression | ObjectPropertyChain:
        cdef void *p = cowl_sub_obj_prop_axiom_get_sub(<CowlSubObjPropAxiom *>self.ptr)
        return Object.retain(p) if cowl_is_obj_prop_exp(p) else Object.retain_as(ObjectPropertyChain, p)

    def parent(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_sub_obj_prop_axiom_get_super(<CowlSubObjPropAxiom *>self.ptr))


cdef class _NaryObjectPropertyAxiom(Axiom):
    def __init__(
        self,
        *args: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlNAryAxiomType ctype = (
             CowlNAryAxiomType.COWL_NAT_EQUIV if type(self) is EquivalentObjectProperties
             else CowlNAryAxiomType.COWL_NAT_DISJ
        )
        cdef Ptr vec = cowl_vector_from_py(args)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_nary_obj_prop_axiom(ctype, <CowlVector *>vec.p, <CowlVector *>annot.p)

    def properties(self) -> Collection[ObjectPropertyExpression]:
        return Object.retain(cowl_nary_obj_prop_axiom_get_props(<CowlNAryObjPropAxiom *>self.ptr))


cdef class EquivalentObjectProperties(_NaryObjectPropertyAxiom):
    pass


cdef class DisjointObjectProperties(_NaryObjectPropertyAxiom):
    pass


cdef class InverseObjectProperties(Axiom):
    def __init__(
        self,
        first: ObjectPropertyExpression,
        second: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_inv_obj_prop_axiom(first.ptr, second.ptr, <CowlVector *>annot.p)

    def first(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_inv_obj_prop_axiom_get_first_prop(<CowlInvObjPropAxiom *>self.ptr))

    def second(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_inv_obj_prop_axiom_get_second_prop(<CowlInvObjPropAxiom *>self.ptr))


cdef class ObjectPropertyDomain(Axiom):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        domain: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_domain_axiom(property_.ptr, domain.ptr, <CowlVector *>annot.p)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_domain_axiom_get_prop(<CowlObjPropDomainAxiom *>self.ptr))

    def domain(self) -> ClassExpression:
        return Object.retain(cowl_obj_prop_domain_axiom_get_domain(<CowlObjPropDomainAxiom *>self.ptr))


cdef class ObjectPropertyRange(Axiom):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        property_range: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_range_axiom(property_.ptr, property_range.ptr, <CowlVector *>annot.p)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_range_axiom_get_prop(<CowlObjPropRangeAxiom *>self.ptr))

    def range(self) -> ClassExpression:
        return Object.retain(cowl_obj_prop_range_axiom_get_range(<CowlObjPropRangeAxiom *>self.ptr))


cdef class _ObjectPropertyCharacteristic(Axiom):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        annotations: Iterable[Annotation] | None = None
    ) -> None:
        cdef CowlCharAxiomType ctype = _cowl_char_axiom_type(type(self))
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_char_axiom(ctype, property_.ptr, <CowlVector *>annot.p)

    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_char_axiom_get_prop(<CowlObjPropCharAxiom *>self.ptr))


cdef class FunctionalObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class InverseFunctionalObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class ReflexiveObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class IrreflexiveObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class SymmetricObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class AsymmetricObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class TransitiveObjectProperty(_ObjectPropertyCharacteristic):
    pass


cdef class SubDataPropertyOf(Axiom):
    def __init__(
        self,
        child: DataProperty,
        parent: DataProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_sub_data_prop_axiom(child.ptr, parent.ptr, <CowlVector *>annot.p)

    def child(self) -> DataProperty:
        return Object.retain(cowl_sub_data_prop_axiom_get_sub(<CowlSubDataPropAxiom *>self.ptr))

    def parent(self) -> DataProperty:
        return Object.retain(cowl_sub_data_prop_axiom_get_super(<CowlSubDataPropAxiom *>self.ptr))


cdef class _NAryDataPropertyAxiom(Axiom):
    def __init__(
        self,
        *args: DataProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlNAryAxiomType ctype = (
            CowlNAryAxiomType.COWL_NAT_EQUIV if type(self) is EquivalentDataProperties
            else CowlNAryAxiomType.COWL_NAT_DISJ
        )
        cdef Ptr vec = cowl_vector_from_py(args)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_nary_data_prop_axiom(ctype, <CowlVector *>vec.p, <CowlVector *>annot.p)

    def properties(self) -> Collection[DataProperty]:
        return Object.retain(cowl_nary_data_prop_axiom_get_props(<CowlNAryDataPropAxiom *>self.ptr))


cdef class EquivalentDataProperties(_NAryDataPropertyAxiom):
    pass


cdef class DisjointDataProperties(_NAryDataPropertyAxiom):
    pass


cdef class DataPropertyDomain(Axiom):
    def __init__(
        self,
        property_: DataProperty,
        domain: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_data_prop_domain_axiom(property_.ptr, domain.ptr, <CowlVector *>annot.p)

    def property_(self) -> DataProperty:
        return Object.retain(cowl_data_prop_domain_axiom_get_prop(<CowlDataPropDomainAxiom *>self.ptr))

    def domain(self) -> ClassExpression:
        return Object.retain(cowl_data_prop_domain_axiom_get_domain(<CowlDataPropDomainAxiom *>self.ptr))


cdef class DataPropertyRange(Axiom):
    def __init__(
        self,
        property_: DataProperty,
        property_range: DataRange,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_data_prop_range_axiom(property_.ptr, property_range.ptr, <CowlVector *>annot.p)

    def property_(self) -> DataProperty:
        return Object.retain(cowl_data_prop_range_axiom_get_prop(<CowlDataPropRangeAxiom *>self.ptr))

    def range(self) -> DataRange:
        return Object.retain(cowl_data_prop_range_axiom_get_range(<CowlDataPropRangeAxiom *>self.ptr))


cdef class FunctionalDataProperty(Axiom):
    def __init__(
        self,
        property_: DataProperty,
        annotations: Iterable[Annotation] | None = None
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_func_data_prop_axiom(property_.ptr, <CowlVector *>annot.p)

    def property_(self) -> DataProperty:
        return Object.retain(cowl_func_data_prop_axiom_get_prop(<CowlFuncDataPropAxiom *>self.ptr))


cdef class DatatypeDefinition(Axiom):
    def __init__(
        self,
        datatype: Datatype,
        data_range: DataRange,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_datatype_def_axiom(<CowlDatatype *>datatype.ptr,
                                           data_range.ptr, <CowlVector *>annot.p)

    def datatype(self) -> Datatype:
        return Object.retain(cowl_datatype_def_axiom_get_datatype(<CowlDatatypeDefAxiom *>self.ptr))

    def data_range(self) -> DataRange:
        return Object.retain(cowl_datatype_def_axiom_get_range(<CowlDatatypeDefAxiom *>self.ptr))


cdef class HasKey(Axiom):
    def __init__(
        self,
        class_: ClassExpression,
        object_properties: Iterable[ObjectPropertyExpression],
        data_properties: Iterable[DataProperty],
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr obj_vec = cowl_vector_from_py(object_properties)
        cdef Ptr data_vec = cowl_vector_from_py(data_properties)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_has_key_axiom(class_.ptr, <CowlVector *>obj_vec.p,
                                      <CowlVector *>data_vec.p, <CowlVector *>annot.p)

    def class_(self) -> ClassExpression:
        return Object.retain(cowl_has_key_axiom_get_cls_exp(<CowlHasKeyAxiom *>self.ptr))

    def object_properties(self) -> Collection[ObjectPropertyExpression]:
        return Object.retain(cowl_has_key_axiom_get_obj_props(<CowlHasKeyAxiom *>self.ptr))

    def data_properties(self) -> Collection[DataProperty]:
        return Object.retain(cowl_has_key_axiom_get_data_props(<CowlHasKeyAxiom *>self.ptr))


cdef class _NAryIndividualAxiom(Axiom):
    def __init__(
        self,
        *args: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlNAryAxiomType ctype = (
            CowlNAryAxiomType.COWL_NAT_SAME if type(self) is SameIndividual
            else CowlNAryAxiomType.COWL_NAT_DIFF
        )
        cdef Ptr ind = cowl_vector_from_py(args)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_nary_ind_axiom(ctype, <CowlVector *>ind.p, <CowlVector *>annot.p)

    def individuals(self) -> Collection[Individual]:
        return Object.retain(cowl_nary_ind_axiom_get_individuals(<CowlNAryIndAxiom *>self.ptr))


cdef class SameIndividual(_NAryIndividualAxiom):
    pass


cdef class DifferentIndividuals(_NAryIndividualAxiom):
    pass


cdef class ClassAssertion(Axiom):
    def __init__(
        self,
        class_: ClassExpression,
        individual: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_cls_assert_axiom(class_.ptr, individual.ptr, <CowlVector *>annot.p)

    def class_expression(self) -> ClassExpression:
        return Object.retain(cowl_cls_assert_axiom_get_cls_exp(<CowlClsAssertAxiom *>self.ptr))

    def individual(self) -> Individual:
        return Object.retain(cowl_cls_assert_axiom_get_ind(<CowlClsAssertAxiom *>self.ptr))


cdef class _ObjectPropertyAssertion(Axiom):
    def property_(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_assert_axiom_get_prop(<CowlObjPropAssertAxiom *>self.ptr))

    def subject(self) -> Individual:
        return Object.retain(cowl_obj_prop_assert_axiom_get_subject(<CowlObjPropAssertAxiom *>self.ptr))

    def object(self) -> Individual:
        return Object.retain(cowl_obj_prop_assert_axiom_get_object(<CowlObjPropAssertAxiom *>self.ptr))


cdef class ObjectPropertyAssertion(_ObjectPropertyAssertion):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        subject: Individual,
        object_: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_assert_axiom(property_.ptr, subject.ptr, object_.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> NegativeObjectPropertyAssertion:
        return NegativeObjectPropertyAssertion(
            self.property_(),
            self.subject(),
            self.object(),
            self.annotations()
        )


cdef class NegativeObjectPropertyAssertion(_ObjectPropertyAssertion):
    def __init__(
        self,
        property_: ObjectPropertyExpression,
        subject: Individual,
        object_: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_neg_obj_prop_assert_axiom(property_.ptr, subject.ptr, object_.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> ObjectPropertyAssertion:
        return ObjectPropertyAssertion(
            self.property_(),
            self.subject(),
            self.object(),
            self.annotations()
        )


cdef class _DataPropertyAssertion(Axiom):
    def property_(self) -> DataProperty:
        return Object.retain(cowl_data_prop_assert_axiom_get_prop(<CowlDataPropAssertAxiom *>self.ptr))

    def subject(self) -> Individual:
        return Object.retain(cowl_data_prop_assert_axiom_get_subject(<CowlDataPropAssertAxiom *>self.ptr))

    def value(self) -> Literal:
        return Object.retain(cowl_data_prop_assert_axiom_get_value(<CowlDataPropAssertAxiom *>self.ptr))


cdef class DataPropertyAssertion(_DataPropertyAssertion):
    def __init__(
        self,
        property_: DataProperty,
        subject: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_data_prop_assert_axiom(property_.ptr, subject.ptr, <CowlLiteral *>value.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> NegativeDataPropertyAssertion:
        return NegativeDataPropertyAssertion(
            self.property_(),
            self.subject(),
            self.value(),
            self.annotations()
        )


cdef class NegativeDataPropertyAssertion(_DataPropertyAssertion):
    def __init__(
        self,
        property_: DataProperty,
        subject: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_neg_data_prop_assert_axiom(property_.ptr, subject.ptr,
                                                   <CowlLiteral *>value.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> DataPropertyAssertion:
        return DataPropertyAssertion(
            self.property_(),
            self.subject(),
            self.value(),
            self.annotations()
        )


cdef class AnnotationAssertion(Axiom):
    def __init__(
        self,
        property_: AnnotationProperty,
        subject: Object,
        value: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_annot_assert_axiom(<CowlAnnotProp *>property_.ptr, subject.ptr,
                                           value.ptr, <CowlVector *>annot.p)

    def property_(self) -> AnnotationProperty:
        return Object.retain(cowl_annot_assert_axiom_get_prop(<CowlAnnotAssertAxiom *>self.ptr))

    def subject(self) -> Object:
        return Object.retain(cowl_annot_assert_axiom_get_subject(<CowlAnnotAssertAxiom *>self.ptr))

    def value(self) -> Object:
        return Object.retain(cowl_annot_assert_axiom_get_value(<CowlAnnotAssertAxiom *>self.ptr))


cdef class SubAnnotationPropertyOf(Axiom):
    def __init__(
        self,
        child: AnnotationProperty,
        parent: AnnotationProperty,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_sub_annot_prop_axiom(<CowlAnnotProp *>child.ptr,
                                             <CowlAnnotProp *>parent.ptr, <CowlVector *>annot.p)

    def child(self) -> AnnotationProperty:
        return Object.retain(cowl_sub_annot_prop_axiom_get_sub(<CowlSubAnnotPropAxiom *>self.ptr))

    def parent(self) -> AnnotationProperty:
        return Object.retain(cowl_sub_annot_prop_axiom_get_super(<CowlSubAnnotPropAxiom *>self.ptr))


cdef class AnnotationPropertyDomain(Axiom):
    def __init__(
        self,
        property_: AnnotationProperty,
        domain: IRI,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_annot_prop_domain_axiom(<CowlAnnotProp *>property_.ptr,
                                                <CowlIRI *>domain.ptr, <CowlVector *>annot.p)

    def property_(self) -> AnnotationProperty:
        return Object.retain(cowl_annot_prop_domain_axiom_get_prop(<CowlAnnotPropDomainAxiom *>self.ptr))

    def domain(self) -> IRI:
        return Object.retain(cowl_annot_prop_domain_axiom_get_domain(<CowlAnnotPropDomainAxiom *>self.ptr))


cdef class AnnotationPropertyRange(Axiom):
    def __init__(
        self,
        property_: AnnotationProperty,
        range_: IRI,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_annot_prop_range_axiom(<CowlAnnotProp *>property_.ptr,
                                               <CowlIRI *>range_.ptr, <CowlVector *>annot.p)

    def property_(self) -> AnnotationProperty:
        return Object.retain(cowl_annot_prop_range_axiom_get_prop(<CowlAnnotPropRangeAxiom *>self.ptr))

    def range(self) -> IRI:
        return Object.retain(cowl_annot_prop_range_axiom_get_range(<CowlAnnotPropRangeAxiom *>self.ptr))


# Ontology


class PrimitiveFactory(Protocol):
    __slots__ = ()

    def IRI(self, iri: str) -> IRI: ...

    def Class(self, iri: str | IRI) -> Class:
        return Class(iri if isinstance(iri, IRI) else self.IRI(iri))

    def Datatype(self, iri: str | IRI) -> Datatype:
        return Datatype(iri if isinstance(iri, IRI) else self.IRI(iri))

    def ObjectProperty(self, iri: str | IRI) -> ObjectProperty:
        return ObjectProperty(iri if isinstance(iri, IRI) else self.IRI(iri))

    def DataProperty(self, iri: str | IRI) -> DataProperty:
        return DataProperty(iri if isinstance(iri, IRI) else self.IRI(iri))

    def AnnotationProperty(self, iri: str | IRI) -> AnnotationProperty:
        return AnnotationProperty(iri if isinstance(iri, IRI) else self.IRI(iri))

    def NamedIndividual(self, iri: str | IRI) -> NamedIndividual:
        return NamedIndividual(iri if isinstance(iri, IRI) else self.IRI(iri))

    def AnonymousIndividual(self, node_id: str | None = None) -> AnonymousIndividual:
        return AnonymousIndividual(node_id)

    @overload
    def Individual(self, iri: str | IRI) -> NamedIndividual: ...

    @overload
    def Individual(self) -> AnonymousIndividual: ...

    def Individual(self, iri: str | IRI | None = None) -> NamedIndividual | AnonymousIndividual:
        return self.NamedIndividual(iri) if iri else self.AnonymousIndividual()


cdef class Ontology(Object, Annotated, HasPrimitives, PrimitiveFactory):
    cdef PrefixMap pm

    @classmethod
    def read(cls, source: IOBase | Path | str) -> Ontology:
        return Reader.default().read(source)

    @property
    def prefix_map(self) -> PrefixMap:
        if self.pm is None:
            self.pm = Object.retain(cowl_ontology_get_prefix_map(<CowlOntology *>self.ptr))
        return self.pm

    def __init__(self) -> None:
        self.ptr = cowl_ontology()

    def __len__(self) -> int:
        return self.axiom_count()

    def __contains__(self, obj: Object) -> bool:
        if obj.is_axiom():
            return cowl_ontology_has_axiom(<CowlOntology *>self.ptr, obj.ptr)
        if obj.is_primitive():
            return cowl_ontology_has_primitive(<CowlOntology *>self.ptr, obj.ptr)
        return False

    def __str__(self) -> str:
        cdef UStrBuf buf = ustrbuf()
        cdef UOStream stream
        uostream_to_strbuf(&stream, &buf)
        cowl_ontology_to_stream(<CowlOntology *>self.ptr, &stream)
        uostream_deinit(&stream)
        return ustrbuf_to_str(&buf)

    def axiom_count(self, arg: Types | Primitive | None = None) -> int:
        cdef CowlOntology *onto = <CowlOntology *>self.ptr
        if arg is None:
            return cowl_ontology_axiom_count(onto)
        if isinstance(arg, Primitive):
            return cowl_ontology_axiom_count_for_primitive(onto, (<Object>arg).ptr)
        return cowl_ontology_axiom_count_for_types(onto, cowl_axiom_flags_from_py(arg))

    def primitive_count(self, types: Types | None = None) -> int:
        cdef CowlOntology *onto = <CowlOntology *>self.ptr
        return cowl_ontology_primitive_count(onto, cowl_primitive_flags_from_py(types))

    def IRI(self, iri: str) -> IRI:
        return self.prefix_map.IRI(iri)

    def iri(self) -> IRI | None:
        cdef CowlIRI *iri_ptr = cowl_ontology_get_iri(<CowlOntology *>self.ptr)
        return Object.retain(iri_ptr) if iri_ptr else None

    def set_iri(self, iri: str | IRI, *, update_prefix: bool = False) -> None:
        cdef IRI iri_obj = _as_iri(iri)
        cowl_ontology_set_iri(<CowlOntology *>self.ptr, <CowlIRI *>iri_obj.ptr)
        if update_prefix:
            iri_str = iri_obj.as_string()
            if not (iri_str.endswith("#") or iri_str.endswith("/")):
                iri_str += "#"
            self.prefix_map[""] = iri_str

    def version(self) -> IRI | None:
        cdef CowlIRI *version_ptr = cowl_ontology_get_version(<CowlOntology *>self.ptr)
        return Object.retain(version_ptr) if version_ptr else None

    def set_version(self, version: str | IRI) -> None:
        cdef IRI iri_obj = _as_iri(version)
        cowl_ontology_set_version(<CowlOntology *>self.ptr, <CowlIRI *>iri_obj.ptr)

    def imports(self) -> Collection[IRI]:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, True)
        cowl_ontology_iterate_imports(<CowlOntology *>self.ptr, &iter)
        return Object.wrap(cowl_vector_wrap(&vec))

    cdef void _foreach_axiom(
        self,
        CowlIterator *iter,
        types: Types | None,
        primitives: OneOrMany | None
    ):
        cdef CowlOntology *onto = <CowlOntology *>self.ptr
        cdef CowlAxiomFilter filter
        primitives = _as_iterable(primitives) if primitives else ()

        if not types and len(primitives) == 1:
            cowl_ontology_iterate_axioms_for_primitive(onto, (<Object>primitives[0]).ptr, iter)
        elif primitives:
            filter = cowl_axiom_filter_from_py(types, primitives)
            cowl_ontology_iterate_axioms_matching(onto, &filter, iter)
        elif types:
            cowl_ontology_iterate_axioms_of_types(onto, cowl_axiom_flags_from_py(types), iter)
        else:
            cowl_ontology_iterate_axioms(onto, iter)

    def foreach_axiom(
        self,
        func: Callable[[Axiom], None],
        types: Types | None = None,
        primitives: OneOrMany | None = None,
    ) -> None:
        cdef CowlIterator iter = cowl_iterator_from_py(func)
        self._foreach_axiom(&iter, types, primitives)

    def axioms(
        self,
        types: Types | None = None,
        primitives: OneOrMany | None = None,
    ) -> Collection[Axiom]:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, True)
        self._foreach_axiom(&iter, types, primitives)
        return Object.wrap(cowl_vector_wrap(&vec))

    cdef void _foreach_related(
        self,
        related: Object,
        axiom_type: type[Axiom],
        CowlIterator *iter,
        position: Position,
    ):
        cdef CowlAxiomType t = _cowl_axiom_type(axiom_type)
        cowl_ontology_iterate_related(<CowlOntology *>self.ptr, related.ptr, t, position.value, iter)

    def foreach_related(
        self,
        func: Callable[[Object], None],
        primitive: Object,
        axiom_type: type[Axiom],
        position: Position = Position.ANY,
    ) -> None:
        cdef CowlIterator iter = cowl_iterator_from_py(func)
        self._foreach_related(primitive, axiom_type, &iter, position)

    def related(
        self,
        primitive: Object,
        axiom_type: type[Axiom],
        position: Position = Position.ANY,
    ) -> Collection[Object]:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, True)
        self._foreach_related(primitive, axiom_type, &iter, position)
        return Object.wrap(cowl_vector_wrap(&vec))

    def _add(self, item: Object) -> None:
        if item.is_axiom():
            cowl_ontology_add_axiom(<CowlOntology *>self.ptr, item.ptr)
        elif isinstance(item, Annotation):
            cowl_ontology_add_annot(<CowlOntology *>self.ptr, <CowlAnnotation *>item.ptr)
        elif isinstance(item, IRI):
            cowl_ontology_add_import(<CowlOntology *>self.ptr, <CowlIRI *>item.ptr)
        else:
            raise TypeError(f"Unsupported item type: {type(item).__name__}")

    def add(self, *args: Object) -> None:
        for item in args:
            self._add(item)

    def _remove(self, item: Object) -> None:
        if item.is_axiom():
            cowl_ontology_remove_axiom(<CowlOntology *>self.ptr, item.ptr)
        elif isinstance(item, Annotation):
            cowl_ontology_remove_annot(<CowlOntology *>self.ptr, <CowlAnnotation *>item.ptr)
        elif isinstance(item, IRI):
            cowl_ontology_remove_import(<CowlOntology *>self.ptr, <CowlIRI *>item.ptr)
        else:
            raise TypeError(f"Unsupported item type: {type(item).__name__}")

    def remove(self, *args: Object) -> None:
        for item in args:
            self._remove(item)

    def write(self, destination: IOBase | Path | str) -> None:
        Writer.default().write(self, destination)


cdef class PrefixMap(Object, MutableMapping, PrimitiveFactory):

    @staticmethod
    def default() -> PrefixMap:
        return Object.retain(cowl_get_prefix_map())

    def IRI(self, iri: str) -> IRI:
        iri_bytes = (iri if ":" in iri else ":" + iri).encode()
        cdef UString iri_str = ustring_wrap_bytes(iri_bytes)
        cdef CowlIRI *iri_ptr = cowl_prefix_map_parse_iri(<CowlPrefixMap *>self.ptr, iri_str)
        return Object.wrap(iri_ptr)

    def __init__(self) -> None:
        self.ptr = cowl_prefix_map()

    def __setitem__(self, prefix: str, ns: str) -> None:
        cdef Ptr p = cowl_string_from_str(prefix)
        cdef Ptr n = cowl_string_from_str(ns)
        cowl_prefix_map_add(<CowlPrefixMap *>self.ptr, <CowlString *>p.p, <CowlString *>n.p, True)

    def __getitem__(self, prefix_or_ns: str) -> str:
        cdef Ptr ptr = cowl_string_from_str(prefix_or_ns)
        cdef CowlString *c_str = <CowlString *>ptr.p
        cdef CowlString *result = cowl_prefix_map_get_ns(<CowlPrefixMap *>self.ptr, c_str)
        if not result:
            result = cowl_prefix_map_get_prefix(<CowlPrefixMap *>self.ptr, c_str)
        if not result:
            raise KeyError(prefix_or_ns)
        return cowl_string_to_str(result)

    def __delitem__(self, prefix_or_ns: str) -> None:
        cdef Ptr ptr = cowl_string_from_str(prefix_or_ns)
        cdef CowlString *c_str = <CowlString *>ptr.p
        cdef cowl_ret ret = cowl_prefix_map_remove_prefix(<CowlPrefixMap *>self.ptr, c_str)
        if ret == Ret.NO:
            ret = cowl_prefix_map_remove_ns(<CowlPrefixMap *>self.ptr, c_str)
        if ret == Ret.NO:
            raise KeyError(prefix_or_ns)

    def __len__(self) -> int:
        return cowl_table_count(cowl_prefix_map_get_table(<CowlPrefixMap *>self.ptr, False))

    def __iter__(self) -> Iterator[str]:
        for prefix, _ in self.items_iter():
            yield prefix

    def items_iter(self) -> Iterator[tuple[str, str]]:
        cdef CowlTable *table = cowl_prefix_map_get_table(<CowlPrefixMap *>self.ptr, False)
        cdef const UHash_CowlObjectPtr *h = cowl_table_get_data(table)
        cdef int size = uhash_size_CowlObjectPtr(h)
        cdef int idx = uhash_next_CowlObjectPtr(h, 0)
        while idx < size:
            key = cowl_string_to_str(<CowlString *>uhash_key_CowlObjectPtr(h, idx))
            value = cowl_string_to_str(<CowlString *>uhmap_val_CowlObjectPtr(h, idx))
            yield (key, value)
            idx = uhash_next_CowlObjectPtr(h, idx + 1)


# Readers and writers


cdef class Header:
    cdef PrefixMap pm
    cdef IRI iri
    cdef IRI version
    cdef Collection imports
    cdef Collection annotations

    @classmethod
    def from_ontology(cls, ontology: Ontology) -> Header:
        return Header(
            prefix_map=ontology.prefix_map,
            iri=ontology.iri(),
            version=ontology.version(),
            imports=ontology.imports(),
            annotations=ontology.annotations(),
        )

    def __init__(
        self,
        prefix_map: PrefixMap | None = None,
        iri: str | IRI | None = None,
        version: str | IRI | None = None,
        imports: Collection[IRI] | None = None,
        annotations: Collection[Annotation] | None = None,
    ) -> None:
        self.pm = prefix_map
        self.iri = _as_iri(iri) if iri else None
        self.version = _as_iri(version) if version else None
        self.imports = imports
        self.annotations = annotations

    cdef CowlOntologyHeader to_cowl(self):
        cdef CowlOntologyHeader header = cowl_ontology_header_empty()
        if self.pm:
            header.pm = <CowlPrefixMap *>self.pm.ptr
        if self.iri:
            header.iri = <CowlIRI *>self.iri.ptr
        if self.version:
            header.version = <CowlIRI *>self.version.ptr
        if self.imports:
            header.imports = cowl_vector_get_data(<CowlVector *>self.imports.ptr)
        if self.annotations:
            header.annotations = cowl_vector_get_data(<CowlVector *>self.annotations.ptr)
        return header


cdef class Reader(Object):

    @classmethod
    def default(cls) -> Reader:
        return Object.wrap(cowl_reader_default())

    @classmethod
    def set_default(cls, reader: Reader) -> None:
        cowl_set_reader(<CowlReader *>reader.ptr)

    @classmethod
    def functional(cls) -> Reader:
        return Object.wrap(cowl_reader_functional())

    def __init__(self) -> None:
        msg = "Use one of the available class methods to create a Reader instance."
        raise NotImplementedError(msg)

    def read(self, source: IOBase | Path | str) -> Ontology:
        cdef CowlReader *reader = <CowlReader *>self.ptr
        cdef cowl_ret ret
        cdef UIStream stream = uistream_from_py(source)
        cdef CowlOntology *onto = cowl_reader_read_ontology(reader, &stream, &ret)
        uistream_deinit(&stream)
        if cowl_is_err(ret):
            cowl_release(onto)
            raise as_exception(ret, cowl_error_to_str(cowl_reader_last_error(reader)))
        return Object.wrap(onto)


cdef class StreamWriter(Object):
    cdef UOStream stream

    @staticmethod
    cdef StreamWriter create(CowlWriter *writer, destination: IOBase | Path | str):
        cdef StreamWriter obj = Object.retain_as(StreamWriter, writer)
        obj.stream = uostream_from_py(destination)
        return obj

    @property
    def written_bytes(self) -> int:
        return self.stream.written_bytes

    def __init__(self) -> None:
        msg = "Use `Writer.stream()` to create a StreamWriter instance."
        raise NotImplementedError(msg)

    def __dealloc__(self) -> None:
        self.close()

    def __enter__(self) -> StreamWriter:
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.write_footer()
        self.close()

    def write(self, construct: Header | Axiom) -> None:
        cdef CowlWriter *writer = <CowlWriter *>self.ptr
        cdef cowl_ret ret
        if isinstance(construct, Header):
            ret = cowl_writer_write_header(writer, &self.stream, (<Header>construct).to_cowl())
        else:
            ret = cowl_writer_write_axiom(writer, &self.stream, (<Axiom>construct).ptr)
        if cowl_is_err(ret):
            raise as_exception(ret)

    def write_footer(self) -> None:
        cdef cowl_ret ret = cowl_writer_write_footer(<CowlWriter *>self.ptr, &self.stream)
        if cowl_is_err(ret):
            raise as_exception(ret)

    def close(self) -> None:
        uostream_deinit(&self.stream)


cdef class Writer(Object):

    @classmethod
    def default(cls) -> Writer:
        return Object.wrap(cowl_writer_default())

    @classmethod
    def set_default(cls, writer: Writer) -> None:
        cowl_set_writer(<CowlWriter *>writer.ptr)

    @classmethod
    def functional(cls) -> Writer:
        return Object.wrap(cowl_writer_functional())

    def __init__(self) -> None:
        msg = "Use one of the available class methods to create a Writer instance."
        raise NotImplementedError(msg)

    def write(self, ontology: Ontology, destination: IOBase | Path | str) -> int:
        cdef UOStream stream = uostream_from_py(destination)
        cdef CowlOntology *onto = <CowlOntology *>ontology.ptr
        cdef ret = cowl_writer_write_ontology(<CowlWriter *>self.ptr, &stream, onto)
        uostream_deinit(&stream)
        if cowl_is_err(ret):
            raise as_exception(ret)
        return stream.written_bytes

    def stream(self, destination: IOBase | Path | str) -> StreamWriter:
        if not cowl_writer_can_write_stream(<CowlWriter *>self.ptr):
            raise NotImplementedError("This writer does not support stream writing.")
        return StreamWriter.create(<CowlWriter *>self.ptr, destination)


# Vocabularies


cdef class OWL:
    prefix = "owl"
    ns = "http://www.w3.org/2002/07/owl#"

    backward_compatible_with = AnnotationProperty(IRI(ns, "backwardCompatibleWith"))
    deprecated = AnnotationProperty(IRI(ns, "deprecated"))
    incompatible_with = AnnotationProperty(IRI(ns, "incompatibleWith"))
    prior_version = AnnotationProperty(IRI(ns, "priorVersion"))
    version_info = AnnotationProperty(IRI(ns, "versionInfo"))

    bottom_data_property = DataProperty(IRI(ns, "bottomDataProperty"))
    bottom_object_property = ObjectProperty(IRI(ns, "bottomObjectProperty"))
    nothing = Class(IRI(ns, "Nothing"))
    rational = Datatype(IRI(ns, "rational"))
    real = Datatype(IRI(ns, "real"))
    thing = Class(IRI(ns, "Thing"))
    top_data_property = DataProperty(IRI(ns, "topDataProperty"))
    top_object_property = ObjectProperty(IRI(ns, "topObjectProperty"))


cdef class RDF:
    prefix = "rdf"
    ns = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

    lang_range = IRI(ns, "langRange")

    lang_string = Datatype(IRI(ns, "langString"))
    plain_literal = Datatype(IRI(ns, "PlainLiteral"))
    xml_literal = Datatype(IRI(ns, "XMLLiteral"))


class RDFS:
    prefix = "rdfs"
    ns = "http://www.w3.org/2000/01/rdf-schema#"

    comment = AnnotationProperty(IRI(ns, "comment"))
    is_defined_by = AnnotationProperty(IRI(ns, "isDefinedBy"))
    label = AnnotationProperty(IRI(ns, "label"))
    see_also = AnnotationProperty(IRI(ns, "seeAlso"))

    literal = Datatype(IRI(ns, "Literal"))


cdef class XSD:
    prefix = "xsd"
    ns = "http://www.w3.org/2001/XMLSchema#"

    length = IRI(ns, "length")
    max_exclusive = IRI(ns, "maxExclusive")
    max_inclusive = IRI(ns, "maxInclusive")
    max_length = IRI(ns, "maxLength")
    min_exclusive = IRI(ns, "minExclusive")
    min_inclusive = IRI(ns, "minInclusive")
    min_length = IRI(ns, "minLength")
    pattern = IRI(ns, "pattern")

    any_uri = Datatype(IRI(ns, "anyURI"))
    base64_binary = Datatype(IRI(ns, "base64Binary"))
    boolean = Datatype(IRI(ns, "boolean"))
    byte = Datatype(IRI(ns, "byte"))
    date_time = Datatype(IRI(ns, "dateTime"))
    date_time_stamp = Datatype(IRI(ns, "dateTimeStamp"))
    decimal = Datatype(IRI(ns, "decimal"))
    double = Datatype(IRI(ns, "double"))
    float = Datatype(IRI(ns, "float"))
    hex_binary = Datatype(IRI(ns, "hexBinary"))
    int = Datatype(IRI(ns, "int"))
    integer = Datatype(IRI(ns, "integer"))
    language = Datatype(IRI(ns, "language"))
    long = Datatype(IRI(ns, "long"))
    name = Datatype(IRI(ns, "Name"))
    ncname = Datatype(IRI(ns, "NCName"))
    negative_integer = Datatype(IRI(ns, "negativeInteger"))
    nmtoken = Datatype(IRI(ns, "NMTOKEN"))
    non_negative_integer = Datatype(IRI(ns, "nonNegativeInteger"))
    non_positive_integer = Datatype(IRI(ns, "nonPositiveInteger"))
    normalized_string = Datatype(IRI(ns, "normalizedString"))
    positive_integer = Datatype(IRI(ns, "positiveInteger"))
    short = Datatype(IRI(ns, "short"))
    string = Datatype(IRI(ns, "string"))
    token = Datatype(IRI(ns, "token"))
    unsigned_byte = Datatype(IRI(ns, "unsignedByte"))
    unsigned_int = Datatype(IRI(ns, "unsignedInt"))
    unsigned_long = Datatype(IRI(ns, "unsignedLong"))
    unsigned_short = Datatype(IRI(ns, "unsignedShort"))


_init()  # Initialize module.
