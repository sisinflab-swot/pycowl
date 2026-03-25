# type: ignore
from typing import Protocol, Type, overload
from ._c_api cimport *


cowl_init()  # Trigger library initialization on import.


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

    def __dealloc__(self) -> None:
        if self.p:
            cowl_release(self.p)


cdef Ptr NULLPtr = Ptr.__new__(Ptr)


cdef UString ustring_from_py(str pystr):
    encoded = pystr.encode()
    return ustring_copy(<const char *>encoded, len(encoded))


cdef str ustring_to_py(UString *ustr, bool deinit = True):
    cdef UString val = ustr[0]
    try:
        ret: str = ustring_data(val)[:ustring_length(val)].decode()
    finally:
        if deinit:
            ustring_deinit(ustr)
    return ret


cdef str ustrbuf_to_py(UStrBuf *buf, bool deinit = True):
    try:
        ret: str = ustrbuf_data(buf)[:ustrbuf_length(buf)].decode()
    finally:
        if deinit:
            ustrbuf_deinit(buf)
    return ret


cdef CowlString *cowl_string_from_py_raw(str s):
    return cowl_string(ustring_from_py(s))


cdef Ptr cowl_string_from_py(str s):
    return Ptr.wrap(cowl_string_from_py_raw(s))


cdef str cowl_string_to_py(CowlString *s):
    return ustring_to_py(<UString *>cowl_string_get_raw(s), deinit=False)


cdef CowlVector *cowl_vector_from_py_raw(items: Iterable[Object] | None):
    if items is None:
        return NULL
    cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
    for item in items:
        uvec_push_CowlObjectPtr(&vec, <CowlObject *>(<Object?>item).ptr)
    return cowl_vector(&vec)


cdef Ptr cowl_vector_from_py(items: Iterable[Object] | None):
    return Ptr.wrap(cowl_vector_from_py_raw(items))


# Utilities


def one_of(*args: Individual | Literal | LiteralValue) -> ObjectOneOf | DataOneOf:
    if isinstance(args[0], Individual):
        return ObjectOneOf(*args)
    return DataOneOf(*(v if isinstance(v, Literal) else Literal(v) for v in args))


# Base types


_TYPES: list[Type[Object]] = []


cdef inline void _populate_types():
    global _TYPES
    _TYPES = [Object] * CowlObjectType.COWL_OT_COUNT
    _TYPES[CowlObjectType.COWL_OT_VECTOR] = Collection
    _TYPES[CowlObjectType.COWL_OT_IRI] = IRI
    _TYPES[CowlObjectType.COWL_OT_LITERAL] = Literal
    _TYPES[CowlObjectType.COWL_OT_ONTOLOGY] = Ontology
    _TYPES[CowlObjectType.COWL_OT_PREFIX_MAP] = PrefixMap
    _TYPES[CowlObjectType.COWL_OT_ANNOTATION] = Annotation
    _TYPES[CowlObjectType.COWL_OT_ANNOT_PROP] = AnnotationProperty
    _TYPES[CowlObjectType.COWL_OT_A_DECL] = Declaration
    _TYPES[CowlObjectType.COWL_OT_A_SUB_CLASS] = SubClassOf
    _TYPES[CowlObjectType.COWL_OT_A_EQUIV_CLASSES] = EquivalentClasses
    _TYPES[CowlObjectType.COWL_OT_A_DISJ_CLASSES] = DisjointClasses
    _TYPES[CowlObjectType.COWL_OT_A_OBJ_PROP_DOMAIN] = ObjectPropertyDomain
    _TYPES[CowlObjectType.COWL_OT_A_OBJ_PROP_RANGE] = ObjectPropertyRange
    _TYPES[CowlObjectType.COWL_OT_A_DATA_PROP_DOMAIN] = DataPropertyDomain
    _TYPES[CowlObjectType.COWL_OT_A_DATA_PROP_RANGE] = DataPropertyRange
    _TYPES[CowlObjectType.COWL_OT_A_CLASS_ASSERT] = ClassAssertion
    _TYPES[CowlObjectType.COWL_OT_A_OBJ_PROP_ASSERT] = ObjectPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_NEG_OBJ_PROP_ASSERT] = NegativeObjectPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_DATA_PROP_ASSERT] = DataPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_A_NEG_DATA_PROP_ASSERT] = NegativeDataPropertyAssertion
    _TYPES[CowlObjectType.COWL_OT_CE_CLASS] = Class
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_INTERSECT] = ObjectIntersectionOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_UNION] = ObjectUnionOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_COMPL] = ObjectComplementOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_ONE_OF] = ObjectOneOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_SOME] = ObjectSomeValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_ALL] = ObjectAllValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_MIN_CARD] = ObjectMinCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_MAX_CARD] = ObjectMaxCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_EXACT_CARD] = ObjectExactCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_SOME] = DataSomeValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_ALL] = DataAllValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_MIN_CARD] = DataMinCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_MAX_CARD] = DataMaxCardinality
    _TYPES[CowlObjectType.COWL_OT_CE_DATA_EXACT_CARD] = DataExactCardinality
    _TYPES[CowlObjectType.COWL_OT_DR_DATATYPE] = Datatype
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_INTERSECT] = DataIntersectionOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_UNION] = DataUnionOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_COMPL] = DataComplementOf
    _TYPES[CowlObjectType.COWL_OT_DR_DATA_ONE_OF] = DataOneOf
    _TYPES[CowlObjectType.COWL_OT_OPE_OBJ_PROP] = ObjectProperty
    _TYPES[CowlObjectType.COWL_OT_OPE_INV_OBJ_PROP] = InverseObjectProperty
    _TYPES[CowlObjectType.COWL_OT_DPE_DATA_PROP] = DataProperty
    _TYPES[CowlObjectType.COWL_OT_I_NAMED] = NamedIndividual
    _TYPES[CowlObjectType.COWL_OT_I_ANONYMOUS] = AnonymousIndividual


cdef _concrete_type(void *ptr):
    if not _TYPES:
        _populate_types()
    return _TYPES[<int>cowl_get_type(ptr)]


cdef class Object:
    cdef void *ptr

    @staticmethod
    cdef Object wrap(void *ptr):
        ctype = _concrete_type(ptr)
        cdef Object obj = ctype.__new__(ctype)
        obj.ptr = ptr
        return obj

    @staticmethod
    cdef Object retain(void *ptr):
        return Object.wrap(cowl_retain(ptr))

    def __cinit__(self):
        self.ptr = NULL

    def __init__(self) -> None:
        raise TypeError("Object cannot be instantiated directly")

    def __dealloc__(self):
        if self.ptr:
            cowl_release(self.ptr)

    def __str__(self) -> str:
        cdef UString str_rep = cowl_to_ustring(self.ptr)
        return ustring_to_py(&str_rep)

    def __repr__(self) -> str:
        cdef UString str_rep = cowl_to_debug_ustring(self.ptr)
        return ustring_to_py(&str_rep)

    def __eq__(self, other: Object) -> bool:
        return cowl_equals(self.ptr, other.ptr)

    def __hash__(self) -> int:
        return hash(cowl_hash(self.ptr))

    cdef bool is_axiom(self):
        return cowl_is_axiom(self.ptr)

    cdef bool is_primitive(self):
        return cowl_is_primitive(self.ptr)

    def iri(self) -> IRI:
        cdef void *iri_ptr = cowl_get_iri(self.ptr)

        if not iri_ptr:
            raise TypeError("Object does not have an IRI")

        return Object.retain(iri_ptr)

    def namespace(self) -> str:
        cdef CowlString *ns_ptr = cowl_get_ns(self.ptr)

        if not ns_ptr:
            raise TypeError("Object does not have a namespace")

        return cowl_string_to_py(ns_ptr)

    def remainder(self) -> str:
        cdef CowlString *rem_ptr = cowl_get_rem(self.ptr)

        if rem_ptr == NULL:
            raise TypeError("Object does not have a remainder")

        return cowl_string_to_py(rem_ptr)

    def annotations(self) -> Collection[Annotation]:
        cdef void *annot_ptr = cowl_get_annot(self.ptr)
        return Object.retain(annot_ptr) if annot_ptr else Collection.empty()

    def is_reserved(self) -> bool:
        return cowl_is_reserved(self.ptr)

    def has_primitive(self, primitive: Object) -> bool:
        return cowl_has_primitive(self.ptr, primitive.ptr)

    def primitives(self) -> Collection[Primitive]:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, False)
        cowl_iterate_primitives(self.ptr, COWL_PF_ALL, &iter)
        return Object.wrap(cowl_vector(&vec))


cdef class AnnotationProperty(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_annot_prop(<CowlIRI *>iri_obj.ptr)


cdef class Annotation(Object):

    def property(self) -> AnnotationProperty:
        return Object.retain(cowl_annotation_get_prop(<CowlAnnotation *>self.ptr))

    def value(self) -> Object:
        return Object.retain(cowl_annotation_get_value(<CowlAnnotation *>self.ptr))


cdef class Collection(Object):

    @staticmethod
    def empty() -> Collection:
        return Object.wrap(cowl_vector_empty())

    def __init__(self, items: Iterable[Object]) -> None:
        self.ptr = cowl_vector_from_py_raw(items)

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


cdef class IRI(Object):

    def __init__(self, prefix: str, suffix: str | None = None) -> None:
        self.ptr = _iri_from_prefix_suffix(prefix, suffix) if suffix else _iri_from_str(prefix)

    def as_string(self) -> str:
        cdef UString iri_str = cowl_iri_to_ustring(<CowlIRI *>self.ptr)
        return ustring_to_py(&iri_str)


cdef inline void *_iri_from_str(str s):
    cdef UString u_str = ustring_from_py(s)
    cdef CowlIRI *ret = cowl_iri_from_string(u_str)
    ustring_deinit(&u_str)
    return ret


cdef inline void *_iri_from_prefix_suffix(str prefix, str suffix):
    cdef Ptr p_ptr = cowl_string_from_py(prefix)
    cdef Ptr s_ptr = cowl_string_from_py(suffix)
    return cowl_iri(<CowlString *>p_ptr.p, <CowlString *>s_ptr.p)


cdef class Literal(Object):
    def __init__(
        self,
        value: LiteralValue,
        datatype: Datatype | None = None,
        language: str | None = None,
    ) -> None:
        value, datatype = _py_to_dt_value(value, datatype)
        cdef CowlDatatype *c_dt = <CowlDatatype *>datatype.ptr if datatype else NULL
        cdef Ptr c_value = cowl_string_from_py(value)
        cdef Ptr c_lang = cowl_string_from_py(language) if language else NULLPtr
        self.ptr = cowl_literal(c_dt, <CowlString *>c_value.p, <CowlString *>c_lang.p)

    def datatype(self) -> Datatype:
        return Object.retain(cowl_literal_get_datatype(<CowlLiteral *>self.ptr))

    def value(self) -> str:
        return cowl_string_to_py(cowl_literal_get_value(<CowlLiteral *>self.ptr))

    def language(self) -> str | None:
        cdef CowlString *c_str = cowl_literal_get_lang(<CowlLiteral *>self.ptr)
        return cowl_string_to_py(c_str) if c_str else None


def _py_to_dt_value(val: object, dt: Datatype | None) -> tuple[str, Datatype | None]:
    if isinstance(val, str):
        return val, dt
    if isinstance(val, bool):
        return "true" if val else "false", dt or XSD.BOOLEAN
    if not dt:
        if isinstance(val, int):
            dt = XSD.INTEGER
        elif isinstance(val, float):
            dt = XSD.DOUBLE
    return str(val), dt


# Class expressions


cdef class ClassExpression(Object):
    def __and__(self, other: ClassExpression) -> ObjectIntersectionOf:
        return ObjectIntersectionOf(
            *self._as_ops(ObjectIntersectionOf),
            *other._as_ops(ObjectIntersectionOf)
        )

    def __or__(self, other: ClassExpression) -> ObjectUnionOf:
        return ObjectUnionOf(
            *self._as_ops(ObjectUnionOf),
            *other._as_ops(ObjectUnionOf)
        )

    def __invert__(self) -> ClassExpression:
        return self.operand() if isinstance(self, ObjectComplementOf) else ObjectComplementOf(self)

    def _as_ops(self, kind: Type[NAryBooleanClassExpression]) -> Iterable[ClassExpression]:
        if isinstance(self, kind):
            return self.operands()
        return (self,)

    def is_a(self, other: ClassExpression) -> SubClassOf:
        return SubClassOf(self, other)

    def subclass_of(self, other: ClassExpression) -> SubClassOf:
        return SubClassOf(self, other)

    def equivalent_to(self, *others: ClassExpression) -> EquivalentClasses:
        return EquivalentClasses(self, *others)

    def disjoint_with(self, *others: ClassExpression) -> DisjointClasses:
        return DisjointClasses(self, *others)

    def that(self, *args: ClassExpression) -> ObjectIntersectionOf:
        return ObjectIntersectionOf(
            *self._as_ops(ObjectIntersectionOf),
            *(op for arg in args for op in arg._as_ops(ObjectIntersectionOf))
        )


cdef class Class(ClassExpression):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_class(<CowlIRI *>iri_obj.ptr)


cdef class NAryBooleanClassExpression(ClassExpression):
    def operands(self) -> Collection:
        return Object.retain(cowl_nary_bool_get_operands(<CowlNAryBool *>self.ptr))


cdef class ObjectIntersectionOf(NAryBooleanClassExpression):

    def __init__(self, *args: ClassExpression) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_nary_bool(CowlNAryType.COWL_NT_INTERSECT, <CowlVector *>vec.p)


cdef class ObjectUnionOf(NAryBooleanClassExpression):

    def __init__(self, *args: ClassExpression) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_nary_bool(CowlNAryType.COWL_NT_UNION, <CowlVector *>vec.p)


cdef class ObjectComplementOf(ClassExpression):
    def __init__(self, operand: ClassExpression) -> None:
        self.ptr = cowl_obj_compl(operand.ptr)

    def operand(self) -> ClassExpression:
        return Object.retain(cowl_obj_compl_get_operand(<CowlObjCompl *>self.ptr))


cdef class ObjectQuantifiedRestriction(ClassExpression):
    def property(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_quant_get_prop(<CowlObjQuant *>self.ptr))

    def filler(self) -> ClassExpression:
        return Object.retain(cowl_obj_quant_get_filler(<CowlObjQuant *>self.ptr))


cdef class ObjectSomeValuesFrom(ObjectQuantifiedRestriction):
    def __init__(self, prop: ObjectPropertyExpression, filler: ClassExpression) -> None:
        cdef CowlQuantType qtype = CowlQuantType.COWL_QT_SOME
        self.ptr = cowl_obj_quant(qtype, (<Object>prop).ptr, (<Object>filler).ptr)


cdef class ObjectAllValuesFrom(ObjectQuantifiedRestriction):
    def __init__(self, prop: ObjectPropertyExpression, filler: ClassExpression) -> None:
        cdef CowlQuantType qtype = CowlQuantType.COWL_QT_ALL
        self.ptr = cowl_obj_quant(qtype, (<Object>prop).ptr, (<Object>filler).ptr)


cdef class ObjectCardinalityRestriction(ClassExpression):
    def property(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_card_get_prop(<CowlObjCard *>self.ptr))

    def cardinality(self) -> int:
        return cowl_obj_card_get_cardinality(<CowlObjCard *>self.ptr)

    def filler(self) -> ClassExpression | None:
        cdef CowlClsExp *filler_ptr = cowl_obj_card_get_filler(<CowlObjCard *>self.ptr)
        return Object.retain(filler_ptr) if filler_ptr else None


cdef class ObjectMinCardinality(ObjectCardinalityRestriction):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None
    ) -> None:
        cdef CowlCardType ctype = CowlCardType.COWL_CT_MIN
        cdef void *filler_ptr = (<Object>filler).ptr if filler else NULL
        self.ptr = cowl_obj_card(ctype, (<Object>prop).ptr, filler_ptr, cardinality)


cdef class ObjectMaxCardinality(ObjectCardinalityRestriction):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None
    ) -> None:
        cdef CowlCardType ctype = CowlCardType.COWL_CT_MAX
        cdef void *filler_ptr = (<Object>filler).ptr if filler else NULL
        self.ptr = cowl_obj_card(ctype, (<Object>prop).ptr, filler_ptr, cardinality)


cdef class ObjectExactCardinality(ObjectCardinalityRestriction):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        cardinality: int,
        filler: ClassExpression | None = None
    ) -> None:
        cdef CowlCardType ctype = CowlCardType.COWL_CT_EXACT
        cdef void *filler_ptr = (<Object>filler).ptr if filler else NULL
        self.ptr = cowl_obj_card(ctype, (<Object>prop).ptr, filler_ptr, cardinality)


cdef class ObjectOneOf(ClassExpression):
    def __init__(self, *inds: Individual) -> None:
        cdef Ptr vec = cowl_vector_from_py(inds)
        self.ptr = cowl_obj_one_of(<CowlVector *>vec.p)

    def individuals(self) -> Collection[Individual]:
        return Object.retain(cowl_obj_one_of_get_inds(<CowlObjOneOf *>self.ptr))


cdef class DataQuantifiedRestriction(ClassExpression):
    def property(self) -> DataProperty:
        return Object.retain(cowl_data_quant_get_prop(<CowlDataQuant *>self.ptr))

    def range(self) -> DataRange:
        return Object.retain(cowl_data_quant_get_range(<CowlDataQuant *>self.ptr))


cdef class DataSomeValuesFrom(ClassExpression):
    def __init__(
        self,
        prop: DataProperty,
        data_range: DataRange
    ) -> None:
        cdef CowlQuantType qtype = CowlQuantType.COWL_QT_SOME
        self.ptr = cowl_data_quant(qtype, prop.ptr, data_range.ptr)


cdef class DataAllValuesFrom(ClassExpression):
    def __init__(
        self,
        prop: DataProperty,
        data_range: DataRange
    ) -> None:
        cdef CowlQuantType qtype = CowlQuantType.COWL_QT_ALL
        self.ptr = cowl_data_quant(qtype, prop.ptr, data_range.ptr)


cdef class DataCardinalityRestriction(ClassExpression):
    def property(self) -> DataProperty:
        return Object.retain(cowl_data_card_get_prop(<CowlDataCard *>self.ptr))

    def cardinality(self) -> int:
        return cowl_data_card_get_cardinality(<CowlDataCard *>self.ptr)

    def filler(self) -> ClassExpression | None:
        cdef CowlDataRange *range = cowl_data_card_get_range(<CowlDataCard *>self.ptr)
        return Object.retain(range) if range else None


cdef class DataMinCardinality(DataCardinalityRestriction):
    def __init__(
        self,
        prop: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None
    ) -> None:
        cdef CowlCardType ctype = CowlCardType.COWL_CT_MIN
        cdef void *range_ptr = data_range.ptr if data_range else NULL
        self.ptr = cowl_data_card(ctype, prop.ptr, range_ptr, cardinality)


cdef class DataMaxCardinality(DataCardinalityRestriction):
    def __init__(
        self,
        prop: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None
    ) -> None:
        cdef CowlCardType ctype = CowlCardType.COWL_CT_MAX
        cdef void *range_ptr = data_range.ptr if data_range else NULL
        self.ptr = cowl_data_card(ctype, prop.ptr, range_ptr, cardinality)


cdef class DataExactCardinality(DataCardinalityRestriction):
    def __init__(
        self,
        prop: DataProperty,
        cardinality: int,
        data_range: DataRange | None = None
    ) -> None:
        cdef CowlCardType ctype = CowlCardType.COWL_CT_EXACT
        cdef void *range_ptr = data_range.ptr if data_range else NULL
        self.ptr = cowl_data_card(ctype, prop.ptr, range_ptr, cardinality)


# Data ranges


cdef class DataRange(Object):
    def __invert__(self) -> DataRange:
        return self.operand() if isinstance(self, DataComplementOf) else DataComplementOf(self)


cdef class Datatype(DataRange):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_datatype(<CowlIRI *>iri_obj.ptr)


cdef class NAryDataRange(DataRange):
    def operands(self) -> Collection[DataRange]:
        return Object.retain(cowl_nary_data_get_operands(<CowlNAryData *>self.ptr))


cdef class DataIntersectionOf(NAryDataRange):
    def __init__(self, *args: DataRange) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_nary_data(CowlNAryType.COWL_NT_INTERSECT, <CowlVector *>vec.p)


cdef class DataUnionOf(NAryDataRange):
    def __init__(self, *args: DataRange) -> None:
        cdef Ptr vec = cowl_vector_from_py(args)
        self.ptr = cowl_nary_data(CowlNAryType.COWL_NT_UNION, <CowlVector *>vec.p)


cdef class DataComplementOf(DataRange):
    def __init__(self, operand: DataRange) -> None:
        self.ptr = cowl_data_compl(operand.ptr)

    def operand(self) -> DataRange:
        return Object.retain(cowl_data_compl_get_operand(<CowlDataCompl *>self.ptr))


cdef class DataOneOf(DataRange):
    def __init__(self, *values: Literal) -> None:
        cdef Ptr vec = cowl_vector_from_py(values)
        self.ptr = cowl_data_one_of(<CowlVector *>vec.p)

    def values(self) -> Collection:
        return Object.retain(cowl_data_one_of_get_values(<CowlDataOneOf *>self.ptr))


# Individuals


cdef class Individual(Object):
    def is_a(self, cls: ClassExpression) -> ClassAssertion:
        return ClassAssertion(cls, self)


cdef class NamedIndividual(Individual):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_named_ind(<CowlIRI *>iri_obj.ptr)


cdef class AnonymousIndividual(Individual):
    def __init__(self, node_id: str | None = None) -> None:
        cdef Ptr c_str = cowl_string_from_py(node_id) if node_id else NULLPtr
        self.ptr = cowl_anon_ind(<CowlString *>c_str.p)


# Object peoperty expressions


cdef class ObjectPropertyExpression(Object):
    def some(self, filler: ClassExpression) -> ObjectSomeValuesFrom:
        return ObjectSomeValuesFrom(self, filler)

    def all(self, filler: ClassExpression) -> ObjectAllValuesFrom:
        return ObjectAllValuesFrom(self, filler)

    def min(self, cardinality: int, filler: ClassExpression | None = None) -> ObjectMinCardinality:
        return ObjectMinCardinality(self, cardinality, filler)

    def max(self, cardinality: int, filler: ClassExpression | None = None) -> ObjectMaxCardinality:
        return ObjectMaxCardinality(self, cardinality, filler)

    def exactly(self, cardinality: int, filler: ClassExpression | None = None) -> ObjectExactCardinality:
        return ObjectExactCardinality(self, cardinality, filler)

    def domain(self, domain: ClassExpression) -> ObjectPropertyDomain:
        return ObjectPropertyDomain(self, domain)

    def range(self, prop_range: ClassExpression) -> ObjectPropertyRange:
        return ObjectPropertyRange(self, prop_range)

    def __call__(self, subj: Individual, obj: Individual) -> ObjectPropertyAssertion:
        return ObjectPropertyAssertion(self, subj, obj)


cdef class ObjectProperty(ObjectPropertyExpression):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_obj_prop(<CowlIRI *>iri_obj.ptr)


cdef class InverseObjectProperty(ObjectPropertyExpression):
    def __init__(self, prop: ObjectProperty) -> None:
        self.ptr = cowl_inv_obj_prop(<CowlObjProp *>prop.ptr)

    def property(self) -> ObjectProperty:
        return Object.retain(cowl_inv_obj_prop_get_prop(<CowlInvObjProp *>self.ptr))


# Data property expressions


cdef class DataProperty(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_data_prop(<CowlIRI *>iri_obj.ptr)

    def __call__(self, subj: Individual, value: Literal | LiteralValue) -> DataPropertyAssertion:
        literal = value if isinstance(value, Literal) else Literal(value)
        return DataPropertyAssertion(self, subj, literal)

    def some(self, data_range: DataRange) -> DataSomeValuesFrom:
        return DataSomeValuesFrom(self, data_range)

    def all(self, data_range: DataRange) -> DataAllValuesFrom:
        return DataAllValuesFrom(self, data_range)

    def min(self, cardinality: int, data_range: DataRange | None = None) -> DataMinCardinality:
        return DataMinCardinality(self, cardinality, data_range)

    def max(self, cardinality: int, data_range: DataRange | None = None) -> DataMaxCardinality:
        return DataMaxCardinality(self, cardinality, data_range)

    def exactly(self, cardinality: int, data_range: DataRange | None = None) -> DataExactCardinality:
        return DataExactCardinality(self, cardinality, data_range)

    def domain(self, domain: ClassExpression) -> DataPropertyDomain:
        return DataPropertyDomain(self, domain)

    def range(self, prop_range: DataRange) -> DataPropertyRange:
        return DataPropertyRange(self, prop_range)


# Axioms


cdef class Axiom(Object):
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
        sub_class: ClassExpression,
        super_class: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_sub_cls_axiom(sub_class.ptr, super_class.ptr, <CowlVector *>annot.p)

    def sub_class(self) -> ClassExpression:
        return Object.retain(cowl_sub_cls_axiom_get_sub(<CowlSubClsAxiom *>self.ptr))

    def super_class(self) -> ClassExpression:
        return Object.retain(cowl_sub_cls_axiom_get_super(<CowlSubClsAxiom *>self.ptr))


cdef class NAryClassAxiom(Axiom):
    def classes(self) -> Collection[ClassExpression]:
        return Object.retain(cowl_nary_cls_axiom_get_classes(<CowlNAryClsAxiom *>self.ptr))


cdef class EquivalentClasses(NAryClassAxiom):
    def __init__(
        self,
        *classes: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr vec = cowl_vector_from_py(classes)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_nary_cls_axiom(CowlNAryAxiomType.COWL_NAT_EQUIV,
                                       <CowlVector *>vec.p, <CowlVector *>annot.p)


cdef class DisjointClasses(NAryClassAxiom):
    def __init__(
        self,
        *classes: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr vec = cowl_vector_from_py(classes)
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_nary_cls_axiom(CowlNAryAxiomType.COWL_NAT_DISJ,
                                       <CowlVector *>vec.p, <CowlVector *>annot.p)


cdef class ClassAssertion(Axiom):
    def __init__(
        self,
        cls: ClassExpression,
        ind: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_cls_assert_axiom(cls.ptr, ind.ptr, <CowlVector *>annot.p)

    def class_expression(self) -> ClassExpression:
        return Object.retain(cowl_cls_assert_axiom_get_cls_exp(<CowlClsAssertAxiom *>self.ptr))

    def individual(self) -> Individual:
        return Object.retain(cowl_cls_assert_axiom_get_ind(<CowlClsAssertAxiom *>self.ptr))


cdef class ObjectPropertyAssertion(Axiom):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        subject: Individual,
        object: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_assert_axiom(prop.ptr, subject.ptr, object.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> ObjectPropertyAssertion:
        return NegativeObjectPropertyAssertion(
            self.property(),
            self.subject(),
            self.object(),
            self.annotations()
        )

    def property(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_assert_axiom_get_prop(<CowlObjPropAssertAxiom *>self.ptr))

    def subject(self) -> Individual:
        return Object.retain(cowl_obj_prop_assert_axiom_get_subject(<CowlObjPropAssertAxiom *>self.ptr))

    def object(self) -> Individual:
        return Object.retain(cowl_obj_prop_assert_axiom_get_object(<CowlObjPropAssertAxiom *>self.ptr))


cdef class NegativeObjectPropertyAssertion(ObjectPropertyAssertion):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        subject: Individual,
        object: Individual,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_neg_obj_prop_assert_axiom(prop.ptr, subject.ptr, object.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> ObjectPropertyAssertion:
        return ObjectPropertyAssertion(
            self.property(),
            self.subject(),
            self.object(),
            self.annotations()
        )


cdef class ObjectPropertyDomain(Axiom):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        domain: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_domain_axiom(prop.ptr, domain.ptr, <CowlVector *>annot.p)

    def property(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_domain_axiom_get_prop(<CowlObjPropDomainAxiom *>self.ptr))

    def domain(self) -> ClassExpression:
        return Object.retain(cowl_obj_prop_domain_axiom_get_domain(<CowlObjPropDomainAxiom *>self.ptr))


cdef class ObjectPropertyRange(Axiom):
    def __init__(
        self,
        prop: ObjectPropertyExpression,
        prop_range: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_range_axiom(prop.ptr, prop_range.ptr, <CowlVector *>annot.p)

    def property(self) -> ObjectPropertyExpression:
        return Object.retain(cowl_obj_prop_range_axiom_get_prop(<CowlObjPropRangeAxiom *>self.ptr))

    def range(self) -> ClassExpression:
        return Object.retain(cowl_obj_prop_range_axiom_get_range(<CowlObjPropRangeAxiom *>self.ptr))


cdef class DataPropertyAssertion(Axiom):
    def __init__(
        self,
        prop: DataProperty,
        subj: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_data_prop_assert_axiom(prop.ptr, subj.ptr, <CowlLiteral *>value.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> DataPropertyAssertion:
        return NegativeDataPropertyAssertion(
            self.property(),
            self.subject(),
            self.value(),
            self.annotations()
        )

    def property(self) -> DataProperty:
        return Object.retain(cowl_data_prop_assert_axiom_get_prop(<CowlDataPropAssertAxiom *>self.ptr))

    def subject(self) -> Individual:
        return Object.retain(cowl_data_prop_assert_axiom_get_subject(<CowlDataPropAssertAxiom *>self.ptr))

    def value(self) -> Literal:
        return Object.retain(cowl_data_prop_assert_axiom_get_object(<CowlDataPropAssertAxiom *>self.ptr))


cdef class NegativeDataPropertyAssertion(DataPropertyAssertion):
    def __init__(
        self,
        prop: DataProperty,
        subj: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_neg_data_prop_assert_axiom(prop.ptr, subj.ptr, <CowlLiteral *>value.ptr, <CowlVector *>annot.p)

    def __invert__(self) -> DataPropertyAssertion:
        return DataPropertyAssertion(
            self.property(),
            self.subject(),
            self.value(),
            self.annotations()
        )


cdef class DataPropertyDomain(Axiom):
    def __init__(
        self,
        prop: DataProperty,
        domain: ClassExpression,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_data_prop_domain_axiom(prop.ptr, domain.ptr, <CowlVector *>annot.p)

    def property(self) -> DataProperty:
        return Object.retain(cowl_data_prop_domain_axiom_get_prop(<CowlDataPropDomainAxiom *>self.ptr))

    def domain(self) -> ClassExpression:
        return Object.retain(cowl_data_prop_domain_axiom_get_domain(<CowlDataPropDomainAxiom *>self.ptr))


cdef class DataPropertyRange(Axiom):
    def __init__(
        self,
        prop: DataProperty,
        prop_range: DataRange,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef Ptr annot = cowl_vector_from_py(annotations)
        self.ptr = cowl_data_prop_range_axiom(prop.ptr, prop_range.ptr, <CowlVector *>annot.p)

    def property(self) -> DataProperty:
        return Object.retain(cowl_data_prop_range_axiom_get_prop(<CowlDataPropRangeAxiom *>self.ptr))

    def range(self) -> DataRange:
        return Object.retain(cowl_data_prop_range_axiom_get_range(<CowlDataPropRangeAxiom *>self.ptr))


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


cdef class Ontology(Object, PrimitiveFactory):
    cdef PrefixMap _pm

    @classmethod
    def at_path(cls, path: Path | str) -> Ontology:
        cdef UString path_str = ustring_from_py(path if isinstance(path, str) else str(path))
        cdef void *ptr = cowl_ontology_at_path(path_str)

        if not ptr:
            msg = f"Failed to load ontology at path: {path}"
            raise ValueError(msg)

        return Object.wrap(ptr)

    @property
    def prefix_map(self) -> PrefixMap:
        if self._pm is None:
            self._pm = Object.retain(cowl_ontology_get_prefix_map(<CowlOntology *>self.ptr))
        return self._pm

    def __init__(self) -> None:
        self.ptr = cowl_ontology()

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
        return ustrbuf_to_py(&buf)

    def IRI(self, iri: str) -> IRI:
        return self.prefix_map.IRI(iri)

    def to_path(self, path: Path | str) -> None:
        cdef UString path_str = ustring_from_py(path if isinstance(path, str) else str(path))
        cowl_ontology_to_path(<CowlOntology *>self.ptr, path_str)
        ustring_deinit(&path_str)

    def set_iri(self, iri: str | IRI, *, update_prefix: bool = False) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        cowl_ontology_set_iri(<CowlOntology *>self.ptr, <CowlIRI *>iri_obj.ptr)
        if update_prefix:
            iri_str = iri_obj.as_string()
            if not (iri_str.endswith("#") or iri_str.endswith("/")):
                iri_str += "#"
            self.prefix_map[""] = iri_str

    def set_version(self, version: str | IRI) -> None:
        cdef IRI iri_obj = version if isinstance(version, IRI) else IRI(version)
        cowl_ontology_set_version(<CowlOntology *>self.ptr, <CowlIRI *>iri_obj.ptr)

    def axioms(self) -> Collection[Axiom]:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, False)
        cowl_ontology_iterate_axioms(<CowlOntology *>self.ptr, &iter)
        return Object.wrap(cowl_vector(&vec))

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


cdef class PrefixMap(Object, PrimitiveFactory):

    @staticmethod
    def default() -> PrefixMap:
        return Object.retain(cowl_get_prefix_map())

    def IRI(self, iri: str) -> IRI:
        cdef UString iri_str = ustring_from_py(iri if ":" in iri else ":" + iri)
        cdef CowlIRI *iri_ptr = cowl_prefix_map_parse_iri(<CowlPrefixMap *>self.ptr, iri_str)
        ustring_deinit(&iri_str)
        return Object.wrap(iri_ptr)

    def __init__(self) -> None:
        self.ptr = cowl_prefix_map()

    def __contains__(self, prefix_or_ns: str) -> bool:
        return self.get(prefix_or_ns) is not None

    def __setitem__(self, prefix: str, ns: str) -> None:
        cdef Ptr p = cowl_string_from_py(prefix)
        cdef Ptr n = cowl_string_from_py(ns)
        cowl_prefix_map_add(<CowlPrefixMap *>self.ptr, <CowlString *>p.p, <CowlString *>n.p, True)

    def __getitem__(self, prefix_or_ns: str) -> str:
        cdef Ptr ptr = cowl_string_from_py(prefix_or_ns)
        cdef CowlString *c_str = <CowlString *>ptr.p
        cdef CowlString *result = cowl_prefix_map_get_ns(<CowlPrefixMap *>self.ptr, c_str)
        if not result:
            result = cowl_prefix_map_get_prefix(<CowlPrefixMap *>self.ptr, c_str)
        if not result:
            raise KeyError(prefix_or_ns)
        return cowl_string_to_py(result)

    def __delitem__(self, prefix_or_ns: str) -> None:
        cdef Ptr ptr = cowl_string_from_py(prefix_or_ns)
        cdef CowlString *c_str = <CowlString *>ptr.p
        cdef cowl_ret ret = cowl_prefix_map_remove_prefix(<CowlPrefixMap *>self.ptr, c_str)
        if ret == Ret.NO:
            ret = cowl_prefix_map_remove_ns(<CowlPrefixMap *>self.ptr, c_str)
        if ret == Ret.NO:
            raise KeyError(prefix_or_ns)

    def __len__(self) -> int:
        return cowl_table_count(cowl_prefix_map_get_table(<CowlPrefixMap *>self.ptr, False))

    def __iter__(self) -> Iterator[str]:
        yield from self.prefixes()

    def items(self) -> Iterator[tuple[str, str]]:
        cdef CowlTable *table = cowl_prefix_map_get_table(<CowlPrefixMap *>self.ptr, False)
        cdef const UHash_CowlObjectPtr *h = cowl_table_get_data(table)
        cdef int size = uhash_size_CowlObjectPtr(h)
        cdef int idx = uhash_next_CowlObjectPtr(h, 0)
        while idx < size:
            key = cowl_string_to_py(<CowlString *>uhash_key_CowlObjectPtr(h, idx))
            value = cowl_string_to_py(<CowlString *>uhmap_val_CowlObjectPtr(h, idx))
            yield (key, value)
            idx = uhash_next_CowlObjectPtr(h, idx + 1)

    def prefixes(self) -> Iterator[str]:
        for prefix, _ in self.items():
            yield prefix

    def namespaces(self) -> Iterator[str]:
        for _, ns in self.items():
            yield ns

    def add(self, prefix: str, ns: str) -> None:
        self[prefix] = ns

    def remove(self, prefix_or_ns: str) -> None:
        try:
            del self[prefix_or_ns]
        except KeyError:
            pass

    def get(self, prefix_or_ns: str) -> str | None:
        try:
            return self[prefix_or_ns]
        except KeyError:
            return None


# Vocabularies


cdef class OWL:
    PREFIX = "owl"
    NS = "http://www.w3.org/2002/07/owl#"

    BACKWARD_COMPATIBLE_WITH = IRI(NS, "backwardCompatibleWith")
    DEPRECATED = IRI(NS, "deprecated")
    INCOMPATIBLE_WITH = IRI(NS, "incompatibleWith")
    PRIOR_VERSION = IRI(NS, "priorVersion")
    VERSION_INFO = IRI(NS, "versionInfo")

    BOTTOM_DATA_PROPERTY = DataProperty(IRI(NS, "bottomDataProperty"))
    BOTTOM_OBJECT_PROPERTY = ObjectProperty(IRI(NS, "bottomObjectProperty"))
    NOTHING = Class(IRI(NS, "Nothing"))
    RATIONAL = Datatype(IRI(NS, "rational"))
    REAL = Datatype(IRI(NS, "real"))
    THING = Class(IRI(NS, "Thing"))
    TOP_DATA_PROPERTY = DataProperty(IRI(NS, "topDataProperty"))
    TOP_OBJECT_PROPERTY = ObjectProperty(IRI(NS, "topObjectProperty"))


cdef class RDF:
    PREFIX = "rdf"
    NS = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

    LANG_RANGE = IRI(NS, "langRange")

    LANG_STRING = Datatype(IRI(NS, "langString"))
    PLAIN_LITERAL = Datatype(IRI(NS, "PlainLiteral"))
    XML_LITERAL = Datatype(IRI(NS, "XMLLiteral"))


class RDFS:
    PREFIX = "rdfs"
    NS = "http://www.w3.org/2000/01/rdf-schema#"

    COMMENT = IRI(NS, "comment")
    IS_DEFINED_BY = IRI(NS, "isDefinedBy")
    LABEL = IRI(NS, "label")
    SEE_ALSO = IRI(NS, "seeAlso")

    LITERAL = Datatype(IRI(NS, "Literal"))


cdef class XSD:
    PREFIX = "xsd"
    NS = "http://www.w3.org/2001/XMLSchema#"

    LENGTH = IRI(NS, "length")
    MAX_EXCLUSIVE = IRI(NS, "maxExclusive")
    MAX_INCLUSIVE = IRI(NS, "maxInclusive")
    MAX_LENGTH = IRI(NS, "maxLength")
    MIN_EXCLUSIVE = IRI(NS, "minExclusive")
    MIN_INCLUSIVE = IRI(NS, "minInclusive")
    MIN_LENGTH = IRI(NS, "minLength")
    PATTERN = IRI(NS, "pattern")

    ANY_URI = Datatype(IRI(NS, "anyURI"))
    BASE64_BINARY = Datatype(IRI(NS, "base64Binary"))
    BOOLEAN = Datatype(IRI(NS, "boolean"))
    BYTE = Datatype(IRI(NS, "byte"))
    DATE_TIME = Datatype(IRI(NS, "dateTime"))
    DATE_TIME_STAMP = Datatype(IRI(NS, "dateTimeStamp"))
    DECIMAL = Datatype(IRI(NS, "decimal"))
    DOUBLE = Datatype(IRI(NS, "double"))
    FLOAT = Datatype(IRI(NS, "float"))
    HEX_BINARY = Datatype(IRI(NS, "hexBinary"))
    INT = Datatype(IRI(NS, "int"))
    INTEGER = Datatype(IRI(NS, "integer"))
    LANGUAGE = Datatype(IRI(NS, "language"))
    LONG = Datatype(IRI(NS, "long"))
    NAME = Datatype(IRI(NS, "Name"))
    NCNAME = Datatype(IRI(NS, "NCName"))
    NEGATIVE_INTEGER = Datatype(IRI(NS, "negativeInteger"))
    NMTOKEN = Datatype(IRI(NS, "NMTOKEN"))
    NON_NEGATIVE_INTEGER = Datatype(IRI(NS, "nonNegativeInteger"))
    NON_POSITIVE_INTEGER = Datatype(IRI(NS, "nonPositiveInteger"))
    NORMALIZED_STRING = Datatype(IRI(NS, "normalizedString"))
    POSITIVE_INTEGER = Datatype(IRI(NS, "positiveInteger"))
    SHORT = Datatype(IRI(NS, "short"))
    STRING = Datatype(IRI(NS, "string"))
    TOKEN = Datatype(IRI(NS, "token"))
    UNSIGNED_BYTE = Datatype(IRI(NS, "unsignedByte"))
    UNSIGNED_INT = Datatype(IRI(NS, "unsignedInt"))
    UNSIGNED_LONG = Datatype(IRI(NS, "unsignedLong"))
    UNSIGNED_SHORT = Datatype(IRI(NS, "unsignedShort"))
