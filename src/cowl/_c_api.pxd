# type: ignore

from libc.stdint cimport uint8_t

cdef extern from "ulib.h":

    ctypedef int ulib_ret

    cdef enum ulib_ret_builtin:
        ULIB_OK
        ULIB_NO
        ULIB_ERR
        ULIB_ERR_MEM
        ULIB_ERR_BOUNDS
        ULIB_ERR_IO

    ctypedef struct UString: pass
    ctypedef struct UStrBuf: pass
    ctypedef struct UOStream: pass

    ulib_ret uostream_to_strbuf(UOStream *stream, UStrBuf *buf)
    ulib_ret uostream_deinit(UOStream *stream)
    const char *ustring_data(UString str)
    int ustring_length(UString str)
    UString ustring_copy(const char *buf, int size)
    UString ustring_wrap(const char *buf, int size)
    void ustring_deinit(UString *str)
    UStrBuf ustrbuf()
    void ustrbuf_deinit(UStrBuf *buf)
    const char *ustrbuf_data(UStrBuf *buf)
    int ustrbuf_length(UStrBuf *buf)
    UString ustrbuf_to_ustring(UStrBuf *buf)


cdef extern from "cowl.h":

    ctypedef int cowl_ret

    ctypedef uint8_t CowlAxiomFlags
    CowlAxiomFlags COWL_AF_NONE
    CowlAxiomFlags COWL_AF_ALL

    ctypedef uint8_t CowlPrimitiveFlags
    CowlPrimitiveFlags COWL_PF_NONE
    CowlPrimitiveFlags COWL_PF_ALL
    CowlPrimitiveFlags COWL_PF_ENTITY
    CowlPrimitiveFlags COWL_PF_IND
    CowlPrimitiveFlags COWL_PF_PROP

    ctypedef uint8_t CowlPosition
    CowlPosition COWL_PS_NONE
    CowlPosition COWL_PS_LEFT
    CowlPosition COWL_PS_RIGHT
    CowlPosition COWL_PS_MIDDLE
    CowlPosition COWL_PS_ANY
    CowlPosition COWL_PS_SUBJECT
    CowlPosition COWL_PS_PREDICATE
    CowlPosition COWL_PS_OBJECT

    ctypedef void CowlAny
    ctypedef void CowlAnyAnnotValue
    ctypedef void CowlAnyAxiom
    ctypedef void CowlAnyClsExp
    ctypedef void CowlAnyDataPropExp
    ctypedef void CowlAnyDataRange
    ctypedef void CowlAnyEntity
    ctypedef void CowlAnyIndividual
    ctypedef void CowlAnyObjPropExp
    ctypedef void CowlAnyPrimitive

    ctypedef struct CowlAnnotAssertAxiom: pass
    ctypedef struct CowlAnnotation: pass
    ctypedef struct CowlAnnotProp: pass
    ctypedef struct CowlAnnotPropDomainAxiom: pass
    ctypedef struct CowlAnnotPropRangeAxiom: pass
    ctypedef struct CowlAnnotValue: pass
    ctypedef struct CowlAnonInd: pass
    ctypedef struct CowlAxiom: pass
    ctypedef struct CowlAxiomFilter: pass
    ctypedef struct CowlClass: pass
    ctypedef struct CowlClsAssertAxiom: pass
    ctypedef struct CowlClsExp: pass
    ctypedef struct CowlDataCard: pass
    ctypedef struct CowlDataCompl: pass
    ctypedef struct CowlDataHasValue: pass
    ctypedef struct CowlDataOneOf: pass
    ctypedef struct CowlDataProp: pass
    ctypedef struct CowlDataPropAssertAxiom: pass
    ctypedef struct CowlDataPropDomainAxiom: pass
    ctypedef struct CowlDataPropExp: pass
    ctypedef struct CowlDataPropRangeAxiom: pass
    ctypedef struct CowlDataQuant: pass
    ctypedef struct CowlDataRange: pass
    ctypedef struct CowlDatatype: pass
    ctypedef struct CowlDatatypeDefAxiom: pass
    ctypedef struct CowlDatatypeRestr: pass
    ctypedef struct CowlDeclAxiom: pass
    ctypedef struct CowlDisjUnionAxiom: pass
    ctypedef struct CowlEntity: pass
    ctypedef struct CowlFacetRestr: pass
    ctypedef struct CowlFilter: pass
    ctypedef struct CowlFuncDataPropAxiom: pass
    ctypedef struct CowlHasKeyAxiom: pass
    ctypedef struct CowlIndividual: pass
    ctypedef struct CowlInvObjProp: pass
    ctypedef struct CowlInvObjPropAxiom: pass
    ctypedef struct CowlIRI: pass
    ctypedef struct CowlIterator:
        void *ctx
        cowl_ret (*for_each)(void *ctx, CowlAny *object)
    ctypedef struct CowlLiteral: pass
    ctypedef struct CowlNamedInd: pass
    ctypedef struct CowlNAryBool: pass
    ctypedef struct CowlNAryClsAxiom: pass
    ctypedef struct CowlNAryData: pass
    ctypedef struct CowlNAryDataPropAxiom: pass
    ctypedef struct CowlNAryIndAxiom: pass
    ctypedef struct CowlNAryObjPropAxiom: pass
    ctypedef struct CowlObjCard: pass
    ctypedef struct CowlObjCompl: pass
    ctypedef struct CowlObject: pass
    ctypedef struct CowlObjHasSelf: pass
    ctypedef struct CowlObjHasValue: pass
    ctypedef struct CowlObjOneOf: pass
    ctypedef struct CowlObjProp: pass
    ctypedef struct CowlObjPropAssertAxiom: pass
    ctypedef struct CowlObjPropCharAxiom: pass
    ctypedef struct CowlObjPropDomainAxiom: pass
    ctypedef struct CowlObjPropExp: pass
    ctypedef struct CowlObjPropRangeAxiom: pass
    ctypedef struct CowlObjQuant: pass
    ctypedef struct CowlOntology: pass
    ctypedef struct CowlPrefixMap: pass
    ctypedef struct CowlString: pass
    ctypedef struct CowlSubAnnotPropAxiom: pass
    ctypedef struct CowlSubClsAxiom: pass
    ctypedef struct CowlSubDataPropAxiom: pass
    ctypedef struct CowlSubObjPropAxiom: pass
    ctypedef struct CowlTable: pass
    ctypedef struct CowlVector: pass
    ctypedef struct UHash_CowlObjectPtr: pass
    ctypedef struct UVec_CowlObjectPtr: pass

    cdef enum CowlObjectType:
        COWL_OT_STRING
        COWL_OT_VECTOR
        COWL_OT_TABLE
        COWL_OT_IRI
        COWL_OT_LITERAL
        COWL_OT_FACET_RESTR
        COWL_OT_ONTOLOGY
        COWL_OT_PREFIX_MAP
        COWL_OT_READER
        COWL_OT_WRITER
        COWL_OT_ANNOTATION
        COWL_OT_ANNOT_PROP
        COWL_OT_A_DECL
        COWL_OT_A_SUB_CLASS
        COWL_OT_A_EQUIV_CLASSES
        COWL_OT_A_DISJ_CLASSES
        COWL_OT_A_DISJ_UNION
        COWL_OT_A_SUB_OBJ_PROP
        COWL_OT_A_EQUIV_OBJ_PROP
        COWL_OT_A_DISJ_OBJ_PROP
        COWL_OT_A_INV_OBJ_PROP
        COWL_OT_A_OBJ_PROP_DOMAIN
        COWL_OT_A_OBJ_PROP_RANGE
        COWL_OT_A_FUNC_OBJ_PROP
        COWL_OT_A_INV_FUNC_OBJ_PROP
        COWL_OT_A_REFL_OBJ_PROP
        COWL_OT_A_IRREFL_OBJ_PROP
        COWL_OT_A_SYMM_OBJ_PROP
        COWL_OT_A_ASYMM_OBJ_PROP
        COWL_OT_A_TRANS_OBJ_PROP
        COWL_OT_A_SUB_DATA_PROP
        COWL_OT_A_EQUIV_DATA_PROP
        COWL_OT_A_DISJ_DATA_PROP
        COWL_OT_A_DATA_PROP_DOMAIN
        COWL_OT_A_DATA_PROP_RANGE
        COWL_OT_A_FUNC_DATA_PROP
        COWL_OT_A_DATATYPE_DEF
        COWL_OT_A_HAS_KEY
        COWL_OT_A_SAME_IND
        COWL_OT_A_DIFF_IND
        COWL_OT_A_CLASS_ASSERT
        COWL_OT_A_OBJ_PROP_ASSERT
        COWL_OT_A_NEG_OBJ_PROP_ASSERT
        COWL_OT_A_DATA_PROP_ASSERT
        COWL_OT_A_NEG_DATA_PROP_ASSERT
        COWL_OT_A_ANNOT_ASSERT
        COWL_OT_A_SUB_ANNOT_PROP
        COWL_OT_A_ANNOT_PROP_DOMAIN
        COWL_OT_A_ANNOT_PROP_RANGE
        COWL_OT_CE_CLASS
        COWL_OT_CE_OBJ_INTERSECT
        COWL_OT_CE_OBJ_UNION
        COWL_OT_CE_OBJ_COMPL
        COWL_OT_CE_OBJ_ONE_OF
        COWL_OT_CE_OBJ_SOME
        COWL_OT_CE_OBJ_ALL
        COWL_OT_CE_OBJ_HAS_VALUE
        COWL_OT_CE_OBJ_HAS_SELF
        COWL_OT_CE_OBJ_MIN_CARD
        COWL_OT_CE_OBJ_MAX_CARD
        COWL_OT_CE_OBJ_EXACT_CARD
        COWL_OT_CE_DATA_SOME
        COWL_OT_CE_DATA_ALL
        COWL_OT_CE_DATA_HAS_VALUE
        COWL_OT_CE_DATA_MIN_CARD
        COWL_OT_CE_DATA_MAX_CARD
        COWL_OT_CE_DATA_EXACT_CARD
        COWL_OT_DR_DATATYPE
        COWL_OT_DR_DATA_INTERSECT
        COWL_OT_DR_DATA_UNION
        COWL_OT_DR_DATA_COMPL
        COWL_OT_DR_DATA_ONE_OF
        COWL_OT_DR_DATATYPE_RESTR
        COWL_OT_OPE_OBJ_PROP
        COWL_OT_OPE_INV_OBJ_PROP
        COWL_OT_DPE_DATA_PROP
        COWL_OT_I_NAMED
        COWL_OT_I_ANONYMOUS
        COWL_OT_COUNT
        COWL_OT_FIRST_A

    cdef enum CowlAxiomType:
        COWL_AT_FIRST
        COWL_AT_COUNT

    cdef enum CowlCardType:
        COWL_CT_MIN
        COWL_CT_MAX
        COWL_CT_EXACT

    cdef enum CowlCharAxiomType:
        COWL_CAT_FUNC
        COWL_CAT_INV_FUNC
        COWL_CAT_REFL
        COWL_CAT_IRREFL
        COWL_CAT_SYMM
        COWL_CAT_ASYMM
        COWL_CAT_TRANS

    cdef enum CowlNAryAxiomType:
        COWL_NAT_EQUIV
        COWL_NAT_DISJ
        COWL_NAT_SAME
        COWL_NAT_DIFF

    cdef enum CowlNAryType:
        COWL_NT_INTERSECT
        COWL_NT_UNION

    cdef enum CowlPrimitiveType:
        COWL_PT_CLASS
        COWL_PT_DATATYPE
        COWL_PT_OBJ_PROP
        COWL_PT_DATA_PROP
        COWL_PT_ANNOT_PROP
        COWL_PT_NAMED_IND
        COWL_PT_ANON_IND
        COWL_PT_IRI

    cdef enum CowlQuantType:
        COWL_QT_SOME
        COWL_QT_ALL

    void cowl_init()
    CowlPrefixMap *cowl_get_prefix_map()
    CowlAny* cowl_retain(CowlAny *object)
    void cowl_release(CowlAny *object)
    CowlObjectType cowl_get_type(CowlAny *object)
    bint cowl_equals(CowlAny *lhs, CowlAny *rhs)
    int cowl_hash(CowlAny *object)
    UString cowl_to_ustring(CowlAny *object)
    UString cowl_to_debug_ustring(CowlAny *object)
    CowlIRI *cowl_get_iri(CowlAny *object)
    CowlString *cowl_get_ns(CowlAny *object)
    CowlString *cowl_get_rem(CowlAny *object)
    CowlVector *cowl_get_annot(CowlAny *object)
    bint cowl_is_axiom(CowlAny *object)
    bint cowl_is_cls_exp(CowlAny *object)
    bint cowl_is_data_prop_exp(CowlAny *object)
    bint cowl_is_data_range(CowlAny *object)
    bint cowl_is_entity(CowlAny *object)
    bint cowl_is_individual(CowlAny *object)
    bint cowl_is_obj_prop_exp(CowlAny *object)
    bint cowl_is_primitive(CowlAny *object)
    bint cowl_is_reserved(CowlAny *object)
    bint cowl_has_primitive(CowlAny *object, CowlAnyPrimitive *primitive)
    cowl_ret cowl_iterate_primitives(CowlAny *object, CowlPrimitiveFlags flags, CowlIterator *iter)
    CowlAnnotAssertAxiom *cowl_annot_assert_axiom(CowlAnnotProp *prop,
        CowlAnyAnnotValue *subject, CowlAnyAnnotValue *value, CowlVector *annot)
    CowlAnnotProp *cowl_annot_assert_axiom_get_prop(CowlAnnotAssertAxiom *axiom)
    CowlAnnotValue *cowl_annot_assert_axiom_get_subject(CowlAnnotAssertAxiom *axiom)
    CowlAnnotValue *cowl_annot_assert_axiom_get_value(CowlAnnotAssertAxiom *axiom)
    CowlAnnotProp *cowl_annot_prop(CowlIRI *iri)
    CowlAnnotPropDomainAxiom *cowl_annot_prop_domain_axiom(CowlAnnotProp *prop,
        CowlIRI *domain, CowlVector *annot)
    CowlAnnotProp *cowl_annot_prop_domain_axiom_get_prop(CowlAnnotPropDomainAxiom *axiom)
    CowlIRI *cowl_annot_prop_domain_axiom_get_domain(CowlAnnotPropDomainAxiom *axiom)
    CowlAnnotPropRangeAxiom *cowl_annot_prop_range_axiom(CowlAnnotProp *prop,
        CowlIRI *range, CowlVector *annot)
    CowlAnnotProp *cowl_annot_prop_range_axiom_get_prop(CowlAnnotPropRangeAxiom *axiom)
    CowlIRI *cowl_annot_prop_range_axiom_get_range(CowlAnnotPropRangeAxiom *axiom)
    CowlAnnotation *cowl_annotation(CowlAnnotProp *prop, CowlAnyAnnotValue *value, CowlVector *annot)
    CowlAnnotProp *cowl_annotation_get_prop(CowlAnnotation *annot)
    CowlAnnotValue *cowl_annotation_get_value(CowlAnnotation *annot)
    CowlVector *cowl_annotation_get_annot(CowlAnnotation *annot)
    CowlAnonInd *cowl_anon_ind(CowlString *id)
    CowlAxiomFilter cowl_axiom_filter(CowlAxiomFlags types)
    void cowl_axiom_filter_deinit(CowlAxiomFilter *filter)
    void cowl_axiom_filter_add_type(CowlAxiomFilter *filter, CowlAxiomType type)
    cowl_ret cowl_axiom_filter_add_primitive(CowlAxiomFilter *filter, CowlAnyPrimitive *primitive)
    void cowl_axiom_filter_set_closure(CowlAxiomFilter *filter, CowlFilter closure)
    CowlAxiomFlags cowl_axiom_flags_add_type(CowlAxiomFlags flags, CowlAxiomType type)
    CowlClass *cowl_class(CowlIRI *iri)
    CowlClsAssertAxiom *cowl_cls_assert_axiom(CowlAnyClsExp *exp, CowlAnyIndividual *ind, CowlVector *annot)
    CowlClsExp *cowl_cls_assert_axiom_get_cls_exp(CowlClsAssertAxiom *axiom)
    CowlIndividual *cowl_cls_assert_axiom_get_ind(CowlClsAssertAxiom *axiom)
    CowlDataCard *cowl_data_card(CowlCardType type, CowlAnyDataPropExp *prop,
        CowlAnyDataRange *range, int cardinality)
    CowlDataPropExp *cowl_data_card_get_prop(CowlDataCard *restr)
    CowlDataRange *cowl_data_card_get_range(CowlDataCard *restr)
    int cowl_data_card_get_cardinality(CowlDataCard *restr)
    CowlDataCompl *cowl_data_compl(CowlAnyDataRange *operand)
    CowlDataRange *cowl_data_compl_get_operand(CowlDataCompl *range)
    CowlDataHasValue *cowl_data_has_value(CowlAnyDataPropExp *prop, CowlLiteral *value)
    CowlDataPropExp *cowl_data_has_value_get_prop(CowlDataHasValue *restr)
    CowlLiteral *cowl_data_has_value_get_value(CowlDataHasValue *restr)
    CowlDataOneOf *cowl_data_one_of(CowlVector *values)
    CowlVector *cowl_data_one_of_get_values(CowlDataOneOf *range)
    CowlDataQuant *cowl_data_quant(CowlQuantType type, CowlAnyDataPropExp *prop, CowlAnyDataRange *range)
    CowlDataPropExp *cowl_data_quant_get_prop(CowlDataQuant *restr)
    CowlDataRange *cowl_data_quant_get_range(CowlDataQuant *restr)
    CowlDataProp *cowl_data_prop(CowlIRI *iri)
    CowlDataPropAssertAxiom *cowl_data_prop_assert_axiom(CowlAnyDataPropExp *prop,
        CowlAnyIndividual *subj, CowlLiteral *obj, CowlVector *annot)
    CowlDataPropAssertAxiom *cowl_neg_data_prop_assert_axiom(CowlAnyDataPropExp *prop,
        CowlAnyIndividual *subj, CowlLiteral *obj, CowlVector *annot)
    CowlDataPropExp *cowl_data_prop_assert_axiom_get_prop(CowlDataPropAssertAxiom *axiom)
    CowlIndividual *cowl_data_prop_assert_axiom_get_subject(CowlDataPropAssertAxiom *axiom)
    CowlLiteral *cowl_data_prop_assert_axiom_get_value(CowlDataPropAssertAxiom *axiom)
    CowlDataPropDomainAxiom *cowl_data_prop_domain_axiom(CowlAnyDataPropExp *prop,
        CowlAnyClsExp *domain, CowlVector *annot)
    CowlDataPropExp *cowl_data_prop_domain_axiom_get_prop(CowlDataPropDomainAxiom *axiom)
    CowlClsExp *cowl_data_prop_domain_axiom_get_domain(CowlDataPropDomainAxiom *axiom)
    CowlDataPropRangeAxiom *cowl_data_prop_range_axiom(CowlAnyDataPropExp *prop,
        CowlAnyDataRange *range, CowlVector *annot)
    CowlDataPropExp *cowl_data_prop_range_axiom_get_prop(CowlDataPropRangeAxiom *axiom)
    CowlDataRange *cowl_data_prop_range_axiom_get_range(CowlDataPropRangeAxiom *axiom)
    CowlDatatype *cowl_datatype(CowlIRI *iri)
    CowlDatatypeDefAxiom *cowl_datatype_def_axiom(CowlDatatype *dt,
        CowlAnyDataRange *range, CowlVector *annot)
    CowlDatatype *cowl_datatype_def_axiom_get_datatype(CowlDatatypeDefAxiom *axiom)
    CowlDataRange *cowl_datatype_def_axiom_get_range(CowlDatatypeDefAxiom *axiom)
    CowlDatatypeRestr *cowl_datatype_restr(CowlDatatype *datatype, CowlVector *restrictions)
    CowlDatatype *cowl_datatype_restr_get_datatype(CowlDatatypeRestr *restr)
    CowlVector *cowl_datatype_restr_get_restrictions(CowlDatatypeRestr *restr)
    CowlDeclAxiom *cowl_decl_axiom(CowlAnyEntity *entity, CowlVector *annot)
    CowlEntity *cowl_decl_axiom_get_entity(CowlDeclAxiom *axiom)
    CowlDisjUnionAxiom *cowl_disj_union_axiom(CowlClass *cls,
        CowlVector *disjoints, CowlVector *annot)
    CowlClass *cowl_disj_union_axiom_get_class(CowlDisjUnionAxiom *axiom)
    CowlVector *cowl_disj_union_axiom_get_disjoints(CowlDisjUnionAxiom *axiom)
    CowlFacetRestr *cowl_facet_restr(CowlIRI *facet, CowlLiteral *value)
    CowlIRI *cowl_facet_restr_get_facet(CowlFacetRestr *restr)
    CowlLiteral *cowl_facet_restr_get_value(CowlFacetRestr *restr)
    CowlFuncDataPropAxiom *cowl_func_data_prop_axiom(CowlAnyDataPropExp *prop, CowlVector *annot)
    CowlDataPropExp *cowl_func_data_prop_axiom_get_prop(CowlFuncDataPropAxiom *axiom)
    CowlHasKeyAxiom *cowl_has_key_axiom(CowlAnyClsExp *cls_exp,
        CowlVector *obj_props, CowlVector *data_props, CowlVector *annot)
    CowlClsExp *cowl_has_key_axiom_get_cls_exp(CowlHasKeyAxiom *axiom)
    CowlVector *cowl_has_key_axiom_get_obj_props(CowlHasKeyAxiom *axiom)
    CowlVector *cowl_has_key_axiom_get_data_props(CowlHasKeyAxiom *axiom)
    CowlInvObjProp *cowl_inv_obj_prop(CowlObjProp *prop)
    CowlObjProp *cowl_inv_obj_prop_get_prop(CowlInvObjProp *inv)
    CowlInvObjPropAxiom *cowl_inv_obj_prop_axiom(CowlAnyObjPropExp *first,
        CowlAnyObjPropExp *second, CowlVector *annot)
    CowlObjPropExp *cowl_inv_obj_prop_axiom_get_first_prop(CowlInvObjPropAxiom *axiom)
    CowlObjPropExp *cowl_inv_obj_prop_axiom_get_second_prop(CowlInvObjPropAxiom *axiom)
    CowlIRI *cowl_iri(CowlString *prefix, CowlString *suffix)
    CowlString *cowl_iri_get_ns(CowlIRI *iri)
    CowlString *cowl_iri_get_rem(CowlIRI *iri)
    CowlIRI *cowl_iri_from_string(UString s)
    CowlString *cowl_iri_get_ns(CowlIRI *iri)
    CowlString *cowl_iri_get_rem(CowlIRI *iri)
    UString cowl_iri_to_ustring(CowlIRI *iri)
    CowlIterator cowl_iterator_vec(UVec_CowlObjectPtr *vec, bint retain)
    CowlLiteral *cowl_literal(CowlString *value, CowlAny *dt_or_lang)
    CowlDatatype *cowl_literal_get_datatype(CowlLiteral *literal)
    CowlString *cowl_literal_get_value(CowlLiteral *literal)
    CowlString *cowl_literal_get_lang(CowlLiteral *literal)
    CowlNamedInd *cowl_named_ind(CowlIRI *iri)
    CowlNAryBool *cowl_nary_bool(CowlNAryType type, CowlVector *operands)
    CowlVector *cowl_nary_bool_get_operands(CowlNAryBool *exp)
    CowlNAryClsAxiom *cowl_nary_cls_axiom(CowlNAryAxiomType type,
        CowlVector *classes, CowlVector *annot)
    CowlVector *cowl_nary_cls_axiom_get_classes(CowlNAryClsAxiom *axiom)
    CowlNAryData *cowl_nary_data(CowlNAryType type, CowlVector *operands)
    CowlVector *cowl_nary_data_get_operands(CowlNAryData *range)
    CowlNAryDataPropAxiom *cowl_nary_data_prop_axiom(CowlNAryAxiomType type,
        CowlVector *props, CowlVector *annot)
    CowlVector *cowl_nary_data_prop_axiom_get_props(CowlNAryDataPropAxiom *axiom)
    CowlNAryIndAxiom *cowl_nary_ind_axiom(CowlNAryAxiomType type,
        CowlVector *individuals, CowlVector *annot)
    CowlVector *cowl_nary_ind_axiom_get_individuals(CowlNAryIndAxiom *axiom)
    CowlNAryObjPropAxiom *cowl_nary_obj_prop_axiom(CowlNAryAxiomType type,
        CowlVector *props, CowlVector *annot)
    CowlVector *cowl_nary_obj_prop_axiom_get_props(CowlNAryObjPropAxiom *axiom)
    CowlObjCard *cowl_obj_card(CowlCardType type, CowlAnyObjPropExp *prop,
        CowlAnyClsExp *filler, int cardinality)
    CowlObjPropExp *cowl_obj_card_get_prop(CowlObjCard *restr)
    CowlClsExp *cowl_obj_card_get_filler(CowlObjCard *restr)
    int cowl_obj_card_get_cardinality(CowlObjCard *restr)
    CowlObjCompl *cowl_obj_compl(CowlAnyClsExp *operand)
    CowlClsExp *cowl_obj_compl_get_operand(CowlObjCompl *exp)
    CowlObjHasSelf *cowl_obj_has_self(CowlAnyObjPropExp *prop)
    CowlObjPropExp *cowl_obj_has_self_get_prop(CowlObjHasSelf *exp)
    CowlObjHasValue *cowl_obj_has_value(CowlAnyObjPropExp *prop, CowlAnyIndividual *individual)
    CowlObjPropExp *cowl_obj_has_value_get_prop(CowlObjHasValue *exp)
    CowlIndividual *cowl_obj_has_value_get_value(CowlObjHasValue *exp)
    CowlObjOneOf *cowl_obj_one_of(CowlVector *inds)
    CowlVector *cowl_obj_one_of_get_inds(CowlObjOneOf *exp)
    CowlObjProp *cowl_obj_prop(CowlIRI *iri)
    CowlObjPropAssertAxiom *cowl_obj_prop_assert_axiom(CowlAnyObjPropExp *prop,
        CowlAnyIndividual *subject, CowlAnyIndividual *object, CowlVector *annot)
    CowlObjPropAssertAxiom *cowl_neg_obj_prop_assert_axiom(CowlAnyObjPropExp *prop,
        CowlAnyIndividual *subject, CowlAnyIndividual *object, CowlVector *annot)
    CowlObjPropExp *cowl_obj_prop_assert_axiom_get_prop(CowlObjPropAssertAxiom *axiom)
    CowlIndividual *cowl_obj_prop_assert_axiom_get_subject(CowlObjPropAssertAxiom *axiom)
    CowlIndividual *cowl_obj_prop_assert_axiom_get_object(CowlObjPropAssertAxiom *axiom)
    CowlObjPropCharAxiom *cowl_obj_prop_char_axiom(CowlCharAxiomType type,
        CowlAnyObjPropExp *prop, CowlVector *annot)
    CowlObjPropExp *cowl_obj_prop_char_axiom_get_prop(CowlObjPropCharAxiom *axiom)
    CowlObjPropDomainAxiom *cowl_obj_prop_domain_axiom(CowlAnyObjPropExp *prop,
        CowlAnyClsExp *domain, CowlVector *annot)
    CowlObjPropExp *cowl_obj_prop_domain_axiom_get_prop(CowlObjPropDomainAxiom *axiom)
    CowlClsExp *cowl_obj_prop_domain_axiom_get_domain(CowlObjPropDomainAxiom *axiom)
    CowlObjPropRangeAxiom *cowl_obj_prop_range_axiom(CowlAnyObjPropExp *prop,
        CowlAnyClsExp *range, CowlVector *annot)
    CowlObjPropExp *cowl_obj_prop_range_axiom_get_prop(CowlObjPropRangeAxiom *axiom)
    CowlClsExp *cowl_obj_prop_range_axiom_get_range(CowlObjPropRangeAxiom *axiom)
    CowlObjQuant *cowl_obj_quant(CowlQuantType type, CowlAnyObjPropExp *prop, CowlAnyClsExp *filler)
    CowlObjPropExp *cowl_obj_quant_get_prop(CowlObjQuant *restr)
    CowlClsExp *cowl_obj_quant_get_filler(CowlObjQuant *restr)
    CowlOntology *cowl_ontology()
    cowl_ret cowl_ontology_add_annot(CowlOntology *onto, CowlAnnotation *annot)
    cowl_ret cowl_ontology_add_axiom(CowlOntology *onto, CowlAnyAxiom *axiom)
    cowl_ret cowl_ontology_add_import(CowlOntology *onto, CowlIRI *iri)
    CowlOntology *cowl_ontology_at_path(UString path)
    int cowl_ontology_axiom_count(CowlOntology *onto)
    int cowl_ontology_axiom_count_for_primitive(CowlOntology *onto, CowlAnyPrimitive *primitive)
    int cowl_ontology_axiom_count_for_types(CowlOntology *onto, CowlAxiomFlags types)
    CowlPrefixMap *cowl_ontology_get_prefix_map(CowlOntology *onto)
    CowlIRI *cowl_ontology_get_version(CowlOntology *onto)
    bint cowl_ontology_has_axiom(CowlOntology *onto, CowlAnyAxiom *axiom)
    bint cowl_ontology_has_primitive(CowlOntology *onto, CowlAnyPrimitive *primitive)
    cowl_ret cowl_ontology_iterate_axioms(CowlOntology *onto, CowlIterator *iter)
    cowl_ret cowl_ontology_iterate_axioms_of_types(CowlOntology *onto,
        CowlAxiomFlags types, CowlIterator *iter)
    cowl_ret cowl_ontology_iterate_axioms_for_primitive(CowlOntology *onto,
        CowlAnyPrimitive *primitive, CowlIterator *iter)
    cowl_ret cowl_ontology_iterate_axioms_matching(CowlOntology *onto,
        CowlAxiomFilter *filter, CowlIterator *iter)
    cowl_ret cowl_ontology_iterate_related(CowlOntology *onto, CowlAnyPrimitive *primitive,
        CowlAxiomType type, CowlPosition position, CowlIterator *iter)
    int cowl_ontology_primitives_count(CowlOntology *onto, CowlPrimitiveFlags flags)
    bint cowl_ontology_remove_annot(CowlOntology *onto, CowlAnnotation *annot)
    bint cowl_ontology_remove_axiom(CowlOntology *onto, CowlAnyAxiom *axiom)
    bint cowl_ontology_remove_import(CowlOntology *onto, CowlIRI *iri)
    cowl_ret cowl_ontology_set_iri(CowlOntology *onto, CowlIRI *iri)
    cowl_ret cowl_ontology_set_version(CowlOntology *onto, CowlIRI *iri)
    cowl_ret cowl_ontology_to_stream(CowlOntology *onto, UOStream *stream)
    cowl_ret cowl_ontology_to_path(CowlOntology *onto, UString path)
    CowlPrefixMap *cowl_prefix_map()
    CowlString *cowl_prefix_map_get_ns(CowlPrefixMap *map, CowlString *prefix)
    CowlString *cowl_prefix_map_get_prefix(CowlPrefixMap *map, CowlString *ns)
    CowlTable *cowl_prefix_map_get_table(CowlPrefixMap *map, bint reverse)
    cowl_ret cowl_prefix_map_add(CowlPrefixMap *map, CowlString *prefix, CowlString *ns, bint overwrite)
    cowl_ret cowl_prefix_map_remove_prefix(CowlPrefixMap *map, CowlString *prefix)
    cowl_ret cowl_prefix_map_remove_ns(CowlPrefixMap *map, CowlString *ns)
    cowl_ret cowl_prefix_map_merge(CowlPrefixMap *dst, CowlPrefixMap *src, bint overwrite)
    CowlIRI *cowl_prefix_map_get_iri(CowlPrefixMap *map, UString prefix, UString rem)
    CowlIRI *cowl_prefix_map_parse_short_iri(CowlPrefixMap *map, UString short_iri)
    CowlIRI *cowl_prefix_map_parse_iri(CowlPrefixMap *map, UString str)
    CowlPrimitiveFlags cowl_primitive_flags_add_type(CowlPrimitiveFlags flags,
        CowlPrimitiveType type)
    CowlString *cowl_string(UString string)
    const UString *cowl_string_get_raw(CowlString *string)
    CowlSubAnnotPropAxiom *cowl_sub_annot_prop_axiom(CowlAnnotProp *sub,
        CowlAnnotProp *super, CowlVector *annot)
    CowlAnnotProp *cowl_sub_annot_prop_axiom_get_sub(CowlSubAnnotPropAxiom *axiom)
    CowlAnnotProp *cowl_sub_annot_prop_axiom_get_super(CowlSubAnnotPropAxiom *axiom)
    CowlSubClsAxiom *cowl_sub_cls_axiom(CowlAnyClsExp *sub, CowlAnyClsExp *super, CowlVector *annot)
    CowlClsExp *cowl_sub_cls_axiom_get_sub(CowlSubClsAxiom *axiom)
    CowlClsExp *cowl_sub_cls_axiom_get_super(CowlSubClsAxiom *axiom)
    CowlSubDataPropAxiom *cowl_sub_data_prop_axiom(CowlAnyDataPropExp *sub,
        CowlAnyDataPropExp *super, CowlVector *annot)
    CowlDataPropExp *cowl_sub_data_prop_axiom_get_sub(CowlSubDataPropAxiom *axiom)
    CowlDataPropExp *cowl_sub_data_prop_axiom_get_super(CowlSubDataPropAxiom *axiom)
    CowlSubObjPropAxiom *cowl_sub_obj_prop_axiom(CowlAnyObjPropExp *sub,
        CowlAnyObjPropExp *super, CowlVector *annot)
    CowlSubObjPropAxiom *cowl_sub_obj_prop_chain_axiom(CowlVector *sub,
        CowlAnyObjPropExp *super, CowlVector *annot)
    CowlAny *cowl_sub_obj_prop_axiom_get_sub(CowlSubObjPropAxiom *axiom)
    CowlObjPropExp *cowl_sub_obj_prop_axiom_get_super(CowlSubObjPropAxiom *axiom)
    const UHash_CowlObjectPtr *cowl_table_get_data(CowlTable *table)
    int cowl_table_count(CowlTable *table)
    CowlAny *cowl_table_get_value(CowlTable *table, CowlAny *key)
    CowlAny *cowl_table_get_any(CowlTable *table)
    bint cowl_table_contains(CowlTable *table, CowlAny *key)
    CowlVector *cowl_vector(UVec_CowlObjectPtr *data)
    CowlVector *cowl_vector_wrap(UVec_CowlObjectPtr *data)
    const UVec_CowlObjectPtr *cowl_vector_get_data(CowlVector *vec)
    int cowl_vector_count(CowlVector *vec)
    CowlAny *cowl_vector_get_item(CowlVector *vec, int idx)
    bint cowl_vector_contains(CowlVector *vec, CowlAny *item)
    int uhash_count_CowlObjectPtr(const UHash_CowlObjectPtr *h)
    CowlAny *uhash_key_CowlObjectPtr(const UHash_CowlObjectPtr *h, int idx)
    int uhash_size_CowlObjectPtr(const UHash_CowlObjectPtr *h)
    int uhash_next_CowlObjectPtr(const UHash_CowlObjectPtr *h, int idx)
    CowlAny *uhmap_val_CowlObjectPtr(const UHash_CowlObjectPtr *h, int idx)
    UVec_CowlObjectPtr uvec_CowlObjectPtr()
    void uvec_deinit_CowlObjectPtr(UVec_CowlObjectPtr *vec)
    ulib_ret uvec_push_CowlObjectPtr(UVec_CowlObjectPtr *vec, CowlObject *item)


cpdef enum Ret:
    OK = ulib_ret_builtin.ULIB_OK
    NO = ulib_ret_builtin.ULIB_NO
    ERR = ulib_ret_builtin.ULIB_ERR
    ERR_MEM = ulib_ret_builtin.ULIB_ERR_MEM
    ERR_BOUNDS = ulib_ret_builtin.ULIB_ERR_BOUNDS
    ERR_IO = ulib_ret_builtin.ULIB_ERR_IO
