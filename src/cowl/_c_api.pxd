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
    ctypedef struct CowlAnnotation: pass
    ctypedef struct CowlAnnotProp: pass
    ctypedef struct CowlAnnotValue: pass
    ctypedef struct CowlAnonInd: pass
    ctypedef struct CowlAxiom: pass
    ctypedef struct CowlClass: pass
    ctypedef struct CowlClsExp: pass
    ctypedef struct CowlDataProp: pass
    ctypedef struct CowlDatatype: pass
    ctypedef struct CowlIRI: pass
    ctypedef struct CowlIterator: pass
    ctypedef struct CowlLiteral: pass
    ctypedef struct CowlNamedInd: pass
    ctypedef struct CowlNAryBool: pass
    ctypedef struct CowlObject: pass
    ctypedef struct CowlObjProp: pass
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
        COWL_NT_INTERSECT,
        COWL_NT_UNION

    void cowl_init()
    void* cowl_retain(void *object)
    void cowl_release(void *object)
    CowlObjectType cowl_get_type(void *object)
    bint cowl_equals(void *lhs, void *rhs)
    int cowl_hash(void *object)
    UString cowl_to_ustring(void *object)
    UString cowl_to_debug_ustring(void *object)
    CowlIRI *cowl_get_iri(void *object)
    CowlString *cowl_get_ns(void *object)
    CowlString *cowl_get_rem(void *object)
    CowlVector *cowl_get_annot(void *object)
    CowlAnnotProp *cowl_annot_prop(CowlIRI *iri)
    CowlAnnotation *cowl_annotation(CowlAnnotProp *prop, void *value, CowlVector *annot)
    CowlAnnotProp *cowl_annotation_get_prop(CowlAnnotation *annot)
    CowlAnnotValue *cowl_annotation_get_value(CowlAnnotation *annot)
    CowlVector *cowl_annotation_get_annot(CowlAnnotation *annot)
    CowlAnonInd *cowl_anon_ind(CowlString *id)
    CowlClass *cowl_class(CowlIRI *iri)
    CowlDataProp *cowl_data_prop(CowlIRI *iri)
    CowlDatatype *cowl_datatype(CowlIRI *iri)
    CowlIRI *cowl_iri(CowlString *prefix, CowlString *suffix)
    CowlIRI *cowl_iri_from_string(UString s)
    CowlString *cowl_iri_get_ns(CowlIRI *iri)
    CowlString *cowl_iri_get_rem(CowlIRI *iri)
    CowlIterator cowl_iterator_vec(UVec_CowlObjectPtr *vec, bint retain)
    CowlLiteral *cowl_literal(CowlDatatype *dt, CowlString *value, CowlString *lang)
    CowlDatatype *cowl_literal_get_datatype(CowlLiteral *literal)
    CowlString *cowl_literal_get_value(CowlLiteral *literal)
    CowlString *cowl_literal_get_lang(CowlLiteral *literal)
    CowlNamedInd *cowl_named_ind(CowlIRI *iri)
    CowlNAryBool *cowl_nary_bool(CowlNAryType type, CowlVector *operands)
    CowlVector *cowl_nary_bool_get_operands(CowlNAryBool *exp)
    CowlObjProp *cowl_obj_prop(CowlIRI *iri)
    CowlOntology *cowl_ontology()
    CowlOntology *cowl_ontology_at_path(UString path)
    cowl_ret cowl_ontology_to_stream(CowlOntology *onto, UOStream *stream)
    cowl_ret cowl_ontology_to_path(CowlOntology *onto, UString path)
    cowl_ret cowl_ontology_iterate_axioms(CowlOntology *onto, CowlIterator *iter)
    cowl_ret cowl_ontology_set_iri(CowlOntology *onto, CowlIRI *iri)
    cowl_ret cowl_ontology_add_axiom(CowlOntology *onto, void *axiom)
    bint cowl_ontology_remove_axiom(CowlOntology *onto, void *axiom)
    CowlString *cowl_string(UString string)
    const UString *cowl_string_get_raw(CowlString *string)
    CowlSubClsAxiom *cowl_sub_cls_axiom(void *sub, void *super, CowlVector *annot)
    CowlClsExp *cowl_sub_cls_axiom_get_sub(CowlSubClsAxiom *axiom)
    CowlClsExp *cowl_sub_cls_axiom_get_super(CowlSubClsAxiom *axiom)
    CowlVector *cowl_vector(UVec_CowlObjectPtr *data)
    int cowl_vector_count(CowlVector *vec)
    void *cowl_vector_get_item(CowlVector *vec, int idx)
    bint cowl_vector_contains(CowlVector *vec, void *item)
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
