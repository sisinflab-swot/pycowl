# type: ignore

from typing import Type
from ._c_api cimport *


cowl_init()  # Trigger library initialization on import.


# C helpers


cdef UString ustring_from_py(str pystr):
    encoded = pystr.encode()
    return ustring_copy(<const char *>encoded, len(pystr))


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


cdef CowlString *cowl_string_from_py(str s):
    return cowl_string(ustring_from_py(s))


cdef str cowl_string_to_py(CowlString *s):
    return ustring_to_py(<UString *>cowl_string_get_raw(s), deinit=False)


cdef CowlVector *cowl_vector_from_py(items: Iterable[Object]):
    cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
    for item in items:
        uvec_push_CowlObjectPtr(&vec, <CowlObject *>(<Object>item).ptr)
    return cowl_vector(&vec)


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
    _TYPES[CowlObjectType.COWL_OT_A_SUB_CLASS] = SubClassOf
    _TYPES[CowlObjectType.COWL_OT_CE_CLASS] = Class
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_INTERSECT] = ObjectIntersectionOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_UNION] = ObjectUnionOf
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_SOME] = ObjectSomeValuesFrom
    _TYPES[CowlObjectType.COWL_OT_CE_OBJ_ALL] = ObjectAllValuesFrom
    _TYPES[CowlObjectType.COWL_OT_DR_DATATYPE] = Datatype
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

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Object):
            return False
        return cowl_equals(self.ptr, (<Object>other).ptr)

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

    def annotations(self) -> Collection:
        cdef void *annot_ptr = cowl_get_annot(self.ptr)
        return Object.retain(annot_ptr) if annot_ptr else Collection.empty()

    def is_reserved(self) -> bool:
        return cowl_is_reserved(self.ptr)

    def has_primitive(self, primitive: Primitive) -> bool:
        return cowl_has_primitive(self.ptr, (<Object>primitive).ptr)

    def primitives(self) -> Collection:
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
        self.ptr = cowl_vector_from_py(items)

    def __len__(self) -> int:
        return cowl_vector_count(<CowlVector *>self.ptr)

    def __contains__(self, item: object) -> bool:
        if not isinstance(item, Object):
            return False
        return cowl_vector_contains(<CowlVector *>self.ptr, (<Object>item).ptr)

    def __iter__(self) -> Iterator[Object]:
        cdef CowlVector *vec = <CowlVector *>self.ptr
        cdef int count = cowl_vector_count(vec)
        cdef int i
        for i in range(count):
            yield Object.retain(cowl_vector_get_item(vec, i))


cdef class Datatype(Object):
    def __init__(self, iri: str | IRI) -> None:
        cdef IRI iri_obj = iri if isinstance(iri, IRI) else IRI(iri)
        self.ptr = cowl_datatype(<CowlIRI *>iri_obj.ptr)


cdef class IRI(Object):

    def __init__(self, prefix: str, suffix: str | None = None) -> None:
        self.ptr = _iri_from_prefix_suffix(prefix, suffix) if suffix else _iri_from_str(prefix)

    def as_string(self) -> str:
        cdef UString iri_str = cowl_iri_to_ustring(<CowlIRI *>self.ptr)
        return ustring_to_py(&iri_str)


cdef inline void *_iri_from_str(str s):
    cdef UString u_str = ustring_from_py(s)
    cdef void *ret = cowl_iri_from_string(u_str)
    ustring_deinit(&u_str)
    return ret


cdef inline void *_iri_from_prefix_suffix(str prefix, str suffix):
    cdef CowlString *c_prefix = cowl_string_from_py(prefix)
    cdef CowlString *c_suffix = cowl_string_from_py(suffix)
    cdef void *ret = cowl_iri(c_prefix, c_suffix)
    cowl_release(c_prefix)
    cowl_release(c_suffix)
    return ret


cdef class Literal(Object):

    def __init__(
        self,
        value: str,
        datatype: Datatype | None = None,
        language: str | None = None,
    ) -> None:
        cdef CowlString *c_value = cowl_string_from_py(value)
        cdef CowlDatatype *c_dt = <CowlDatatype *>datatype.ptr if datatype else NULL
        cdef CowlString *c_lang = cowl_string_from_py(language) if language else NULL
        self.ptr = cowl_literal(c_dt, c_value, c_lang)
        cowl_release(c_value)
        cowl_release(c_lang)

    def datatype(self) -> Datatype:
        return Object.retain(cowl_literal_get_datatype(<CowlLiteral *>self.ptr))

    def value(self) -> str:
        return cowl_string_to_py(cowl_literal_get_value(<CowlLiteral *>self.ptr))

    def language(self) -> str | None:
        cdef CowlString *c_str = cowl_literal_get_lang(<CowlLiteral *>self.ptr)
        return cowl_string_to_py(c_str) if c_str else None


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

    def __invert__(self) -> ObjectComplementOf:
        return self.operand() if isinstance(self, ObjectComplementOf) else ObjectComplementOf(self)

    def _as_ops(self, kind: Type[NAryBooleanClassExpression]) -> Iterable[ClassExpression]:
        if isinstance(self, kind):
            return self.operands()
        return (self,)

    def is_a(self, other: ClassExpression) -> SubClassOf:
        return SubClassOf(self, other)

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

    def __init__(self, *args: Object) -> None:
        cdef CowlNAryType ctype = CowlNAryType.COWL_NT_INTERSECT
        self.ptr = cowl_nary_bool(ctype, cowl_vector_from_py(args))


cdef class ObjectUnionOf(NAryBooleanClassExpression):

    def __init__(self, *args: Object) -> None:
        cdef CowlNAryType ctype = CowlNAryType.COWL_NT_UNION
        self.ptr = cowl_nary_bool(ctype, cowl_vector_from_py(args))


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
        cdef CowlString *c_str = cowl_string_from_py(node_id) if node_id else NULL
        self.ptr = cowl_anon_ind(c_str)


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

    def __call__(self, subj: Individual, obj: Literal) -> DataPropertyAssertion:
        return DataPropertyAssertion(self, subj, obj)


# Axioms


cdef class Axiom(Object):
    pass


cdef class Declaration(Axiom):
    def __init__(
        self,
        entity: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        self.ptr = cowl_decl_axiom(entity.ptr, annot)
        cowl_release(annot)

    def entity(self) -> Object:
        return Object.retain(cowl_decl_axiom_get_entity(<CowlDeclAxiom *>self.ptr))


cdef class SubClassOf(Axiom):

    def __init__(
        self,
        sub_class: Object,
        super_class: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        self.ptr = cowl_sub_cls_axiom(sub_class.ptr, super_class.ptr, annot)
        cowl_release(annot)

    def sub_class(self) -> Object:
        return Object.retain(cowl_sub_cls_axiom_get_sub(<CowlSubClsAxiom *>self.ptr))

    def super_class(self) -> Object:
        return Object.retain(cowl_sub_cls_axiom_get_super(<CowlSubClsAxiom *>self.ptr))


cdef class ClassAssertion(Axiom):
    def __init__(
        self,
        cls: Object,
        ind: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        self.ptr = cowl_cls_assert_axiom(cls.ptr, ind.ptr, annot)
        cowl_release(annot)

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
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        self.ptr = cowl_obj_prop_assert_axiom(prop.ptr, subject.ptr, object.ptr, annot)
        cowl_release(annot)

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
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        self.ptr = cowl_neg_obj_prop_assert_axiom(prop.ptr, subject.ptr, object.ptr, annot)
        cowl_release(annot)

    def __invert__(self) -> ObjectPropertyAssertion:
        return ObjectPropertyAssertion(
            self.property(),
            self.subject(),
            self.object(),
            self.annotations()
        )


cdef class DataPropertyAssertion(Axiom):
    def __init__(
        self,
        prop: DataProperty,
        subj: Individual,
        value: Literal,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        cdef CowlLiteral *lit = <CowlLiteral *>value.ptr
        self.ptr = cowl_data_prop_assert_axiom(prop.ptr, subj.ptr, lit, annot)
        cowl_release(annot)

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
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        cdef CowlLiteral *lit = <CowlLiteral *>value.ptr
        self.ptr = cowl_neg_data_prop_assert_axiom(prop.ptr, subj.ptr, lit, annot)
        cowl_release(annot)

    def __invert__(self) -> DataPropertyAssertion:
        return DataPropertyAssertion(
            self.property(),
            self.subject(),
            self.value(),
            self.annotations()
        )


# Ontology


cdef class Ontology(Object):
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

    def __contains__(self, item: object) -> bool:
        if not isinstance(item, Object):
            return False
        cdef Object obj = <Object>item
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

    def axioms(self) -> Collection:
        cdef UVec_CowlObjectPtr vec = uvec_CowlObjectPtr()
        cdef CowlIterator iter = cowl_iterator_vec(&vec, False)
        cowl_ontology_iterate_axioms(<CowlOntology *>self.ptr, &iter)
        return Object.wrap(cowl_vector(&vec))

    def _add(self, item: Object) -> None:
        if isinstance(item, Annotation):
            cowl_ontology_add_annot(<CowlOntology *>self.ptr, <CowlAnnotation *>item.ptr)
        elif isinstance(item, IRI):
            cowl_ontology_add_import(<CowlOntology *>self.ptr, <CowlIRI *>item.ptr)
        else:
            cowl_ontology_add_axiom(<CowlOntology *>self.ptr, item.ptr)

    def add(self, *args: Object) -> None:
        for item in args:
            self._add(item)

    def _remove(self, item: Object) -> None:
        if isinstance(item, Annotation):
            cowl_ontology_remove_annot(<CowlOntology *>self.ptr, <CowlAnnotation *>item.ptr)
        elif isinstance(item, IRI):
            cowl_ontology_remove_import(<CowlOntology *>self.ptr, <CowlIRI *>item.ptr)
        else:
            cowl_ontology_remove_axiom(<CowlOntology *>self.ptr, item.ptr)

    def remove(self, *args: Object) -> None:
        for item in args:
            self._remove(item)


cdef class PrefixMap(Object):
    @staticmethod
    def default() -> PrefixMap:
        return Object.retain(cowl_get_prefix_map())

    def __init__(self) -> None:
        self.ptr = cowl_prefix_map()

    def __contains__(self, prefix_or_ns: str) -> bool:
        return self.get(prefix_or_ns) is not None

    def __setitem__(self, prefix: str, ns: str) -> None:
        cdef CowlString *c_prefix = cowl_string_from_py(prefix)
        cdef CowlString *c_ns = cowl_string_from_py(ns)
        cowl_prefix_map_add(<CowlPrefixMap *>self.ptr, c_prefix, c_ns, True)
        cowl_release(c_prefix)
        cowl_release(c_ns)

    def __getitem__(self, prefix_or_ns: str) -> str:
        cdef CowlString *c_str = cowl_string_from_py(prefix_or_ns)
        cdef CowlString *result = cowl_prefix_map_get_ns(<CowlPrefixMap *>self.ptr, c_str)
        if not result:
            result = cowl_prefix_map_get_prefix(<CowlPrefixMap *>self.ptr, c_str)
        cowl_release(c_str)
        if not result:
            raise KeyError(prefix_or_ns)
        return cowl_string_to_py(result)

    def __delitem__(self, prefix_or_ns: str) -> None:
        cdef CowlString *c_str = cowl_string_from_py(prefix_or_ns)
        cdef cowl_ret ret = cowl_prefix_map_remove_prefix(<CowlPrefixMap *>self.ptr, c_str)
        if ret == Ret.NO:
            ret = cowl_prefix_map_remove_ns(<CowlPrefixMap *>self.ptr, c_str)
        cowl_release(c_str)
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
