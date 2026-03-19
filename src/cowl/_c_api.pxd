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

    ctypedef uint8_t CowlPrimitiveFlags
    CowlPrimitiveFlags COWL_PF_NONE
    CowlPrimitiveFlags COWL_PF_ALL
    CowlPrimitiveFlags COWL_PF_CLASS
    CowlPrimitiveFlags COWL_PF_DATATYPE
    CowlPrimitiveFlags COWL_PF_OBJ_PROP
    CowlPrimitiveFlags COWL_PF_DATA_PROP
    CowlPrimitiveFlags COWL_PF_ANNOT_PROP
    CowlPrimitiveFlags COWL_PF_NAMED_IND
    CowlPrimitiveFlags COWL_PF_ANON_IND
    CowlPrimitiveFlags COWL_PF_IRI
    CowlPrimitiveFlags COWL_PF_ENTITY

    ctypedef void CowlAny
    ctypedef void CowlAnyAnnotValue
    ctypedef void CowlAnyAxiom
    ctypedef void CowlAnyClsExp
    ctypedef void CowlAnyIndividual
    ctypedef void CowlAnyObjPropExp
    ctypedef void CowlAnyPrimitive

    ctypedef struct CowlAnnotation: pass
    ctypedef struct CowlAnnotProp: pass
    ctypedef struct CowlAnnotValue: pass
    ctypedef struct CowlAnonInd: pass
    ctypedef struct CowlAxiom: pass
    ctypedef struct CowlClass: pass
    ctypedef struct CowlClsAssertAxiom: pass
    ctypedef struct CowlClsExp: pass
    ctypedef struct CowlDataProp: pass
    ctypedef struct CowlDatatype: pass
    ctypedef struct CowlIndividual: pass
    ctypedef struct CowlInvObjProp: pass
    ctypedef struct CowlIRI: pass
    ctypedef struct CowlIterator: pass
    ctypedef struct CowlLiteral: pass
    ctypedef struct CowlNamedInd: pass
    ctypedef struct CowlNAryBool: pass
    ctypedef struct CowlObject: pass
    ctypedef struct CowlObjProp: pass
    ctypedef struct CowlObjPropExp: pass
    ctypedef struct CowlObjQuant: pass
    ctypedef struct CowlOntology: pass
    ctypedef struct CowlString: pass
    ctypedef struct CowlSubClsAxiom: pass
    ctypedef struct CowlVector: pass
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

    cdef enum CowlNAryType:
        COWL_NT_INTERSECT
        COWL_NT_UNION

    cdef enum CowlQuantType:
        COWL_QT_SOME
        COWL_QT_ALL

    void cowl_init()
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
    bint cowl_is_reserved(CowlAny *object)
    bint cowl_has_primitive(CowlAny *object, CowlAnyPrimitive *primitive)
    cowl_ret cowl_iterate_primitives(CowlAny *object, CowlPrimitiveFlags flags, CowlIterator *iter)
    CowlAnnotProp *cowl_annot_prop(CowlIRI *iri)
    CowlAnnotation *cowl_annotation(CowlAnnotProp *prop, CowlAnyAnnotValue *value, CowlVector *annot)
    CowlAnnotProp *cowl_annotation_get_prop(CowlAnnotation *annot)
    CowlAnnotValue *cowl_annotation_get_value(CowlAnnotation *annot)
    CowlVector *cowl_annotation_get_annot(CowlAnnotation *annot)
    CowlAnonInd *cowl_anon_ind(CowlString *id)
    CowlClass *cowl_class(CowlIRI *iri)
    CowlClsAssertAxiom *cowl_cls_assert_axiom(CowlAnyClsExp *exp, CowlAnyIndividual *ind, CowlVector *annot)
    CowlClsExp *cowl_cls_assert_axiom_get_cls_exp(CowlClsAssertAxiom *axiom)
    CowlIndividual *cowl_cls_assert_axiom_get_ind(CowlClsAssertAxiom *axiom)
    CowlDataProp *cowl_data_prop(CowlIRI *iri)
    CowlDatatype *cowl_datatype(CowlIRI *iri)
    CowlInvObjProp *cowl_inv_obj_prop(CowlObjProp *prop)
    CowlObjProp *cowl_inv_obj_prop_get_prop(CowlInvObjProp *inv)
    CowlIRI *cowl_iri(CowlString *prefix, CowlString *suffix)
    CowlIRI *cowl_iri_from_string(UString s)
    CowlString *cowl_iri_get_ns(CowlIRI *iri)
    CowlString *cowl_iri_get_rem(CowlIRI *iri)
    UString cowl_iri_to_ustring(CowlIRI *iri)
    CowlIterator cowl_iterator_vec(UVec_CowlObjectPtr *vec, bint retain)
    CowlLiteral *cowl_literal(CowlDatatype *dt, CowlString *value, CowlString *lang)
    CowlDatatype *cowl_literal_get_datatype(CowlLiteral *literal)
    CowlString *cowl_literal_get_value(CowlLiteral *literal)
    CowlString *cowl_literal_get_lang(CowlLiteral *literal)
    CowlNamedInd *cowl_named_ind(CowlIRI *iri)
    CowlNAryBool *cowl_nary_bool(CowlNAryType type, CowlVector *operands)
    CowlVector *cowl_nary_bool_get_operands(CowlNAryBool *exp)
    CowlObjProp *cowl_obj_prop(CowlIRI *iri)
    CowlObjQuant *cowl_obj_quant(CowlQuantType type, CowlAnyObjPropExp *prop, CowlAnyClsExp *filler)
    CowlObjPropExp *cowl_obj_quant_get_prop(CowlObjQuant *restr)
    CowlClsExp *cowl_obj_quant_get_filler(CowlObjQuant *restr)
    CowlOntology *cowl_ontology()
    CowlOntology *cowl_ontology_at_path(UString path)
    cowl_ret cowl_ontology_to_stream(CowlOntology *onto, UOStream *stream)
    cowl_ret cowl_ontology_to_path(CowlOntology *onto, UString path)
    cowl_ret cowl_ontology_iterate_axioms(CowlOntology *onto, CowlIterator *iter)
    cowl_ret cowl_ontology_set_iri(CowlOntology *onto, CowlIRI *iri)
    cowl_ret cowl_ontology_add_axiom(CowlOntology *onto, CowlAnyAxiom *axiom)
    bint cowl_ontology_remove_axiom(CowlOntology *onto, CowlAnyAxiom *axiom)
    CowlString *cowl_string(UString string)
    const UString *cowl_string_get_raw(CowlString *string)
    CowlSubClsAxiom *cowl_sub_cls_axiom(CowlAnyClsExp *sub, CowlAnyClsExp *super, CowlVector *annot)
    CowlClsExp *cowl_sub_cls_axiom_get_sub(CowlSubClsAxiom *axiom)
    CowlClsExp *cowl_sub_cls_axiom_get_super(CowlSubClsAxiom *axiom)
    CowlVector *cowl_vector(UVec_CowlObjectPtr *data)
    int cowl_vector_count(CowlVector *vec)
    CowlAny *cowl_vector_get_item(CowlVector *vec, int idx)
    bint cowl_vector_contains(CowlVector *vec, CowlAny *item)
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
