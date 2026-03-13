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
    bint cowl_equals(void *lhs, void *rhs)
    int cowl_hash(void *object)
    UString cowl_to_ustring(void *object)
    UString cowl_to_debug_ustring(void *object)


cdef extern from "cowl_ontology.h":

    ctypedef struct CowlOntology:
        pass

    CowlOntology *cowl_ontology()
    CowlOntology *cowl_ontology_at_path(UString path)
    cowl_ret cowl_ontology_to_stream(CowlOntology *onto, UOStream *stream)
    cowl_ret cowl_ontology_to_path(CowlOntology *onto, UString path)
    cowl_ret cowl_ontology_iterate_axioms(CowlOntology *onto, CowlIterator *iter)
