from .ulib cimport UOStream, UString, ulib_ret_builtin


cpdef enum Ret:
    OK = ulib_ret_builtin.ULIB_OK
    NO = ulib_ret_builtin.ULIB_NO
    ERR = ulib_ret_builtin.ULIB_ERR
    ERR_MEM = ulib_ret_builtin.ULIB_ERR_MEM
    ERR_BOUNDS = ulib_ret_builtin.ULIB_ERR_BOUNDS
    ERR_IO = ulib_ret_builtin.ULIB_ERR_IO


cdef extern from "cowl_config.h":
    void cowl_init()


cdef extern from "cowl_ret.h":

    ctypedef int cowl_ret


cdef extern from "cowl_object_type.h":

    cpdef enum CowlObjectType:
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


cdef extern from "cowl_string.h":

    cdef struct CowlString:
        pass

    CowlString *cowl_string(UString string)
    const UString *cowl_string_get_raw(CowlString *string)


cdef extern from "cowl_iri.h":

    cdef struct CowlIRI:
        pass

    CowlIRI *cowl_iri(CowlString *prefix, CowlString *suffix)
    CowlIRI *cowl_iri_from_string(UString s)
    CowlString *cowl_iri_get_ns(CowlIRI *iri)
    CowlString *cowl_iri_get_rem(CowlIRI *iri)


cdef extern from "cowl_vector.h":

    ctypedef struct UVec_CowlObjectPtr:
        pass

    UVec_CowlObjectPtr uvec_CowlObjectPtr()
    void uvec_deinit_CowlObjectPtr(UVec_CowlObjectPtr *vec)

    ctypedef struct CowlVector:
        pass

    CowlVector *cowl_vector(UVec_CowlObjectPtr *data)
    int cowl_vector_count(CowlVector *vec)
    void *cowl_vector_get_item(CowlVector *vec, int idx)
    bint cowl_vector_contains(CowlVector *vec, void *item)


cdef extern from "cowl_iterator.h":

    ctypedef struct CowlIterator:
        pass

    CowlIterator cowl_iterator_vec(UVec_CowlObjectPtr *vec, bint retain)


cdef extern from "cowl_object.h":

    ctypedef struct CowlObject:
        pass

    void* cowl_retain(void *object)
    void cowl_release(void *object)
    CowlObjectType cowl_get_type(void *object)
    bint cowl_equals(void *lhs, void *rhs)
    int cowl_hash(void *object)
    UString cowl_to_ustring(void *object)
    UString cowl_to_debug_ustring(void *object)
    CowlVector *cowl_get_annot(void *object)


cdef extern from "cowl_axiom.h":

    ctypedef struct CowlAxiom:
        pass


cdef extern from "cowl_ontology.h":

    ctypedef struct CowlOntology:
        pass

    CowlOntology *cowl_ontology()
    CowlOntology *cowl_ontology_at_path(UString path)
    cowl_ret cowl_ontology_to_stream(CowlOntology *onto, UOStream *stream)
    cowl_ret cowl_ontology_to_path(CowlOntology *onto, UString path)
    cowl_ret cowl_ontology_iterate_axioms(CowlOntology *onto, CowlIterator *iter)


cdef CowlString *cowl_string_from_py(str s)
cdef str cowl_string_to_py(CowlString *s)
