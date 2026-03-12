from cowl.ulib cimport UOStream, UString, ulib_ret_builtin


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


cdef extern from "cowl_object.h":

    ctypedef struct CowlObject:
        pass

    void* cowl_retain(void* object)
    void cowl_release(void* object)
    bint cowl_equals(void *lhs, void *rhs)
    UString cowl_to_ustring(void *object)
    UString cowl_to_debug_ustring(void *object)


cdef extern from "cowl_ontology.h":

    ctypedef struct CowlOntology:
        pass

    CowlOntology *cowl_ontology()
    CowlOntology *cowl_ontology_at_path(UString path)
    cowl_ret cowl_ontology_to_stream(CowlOntology *onto, UOStream *stream)
    cowl_ret cowl_ontology_to_path(CowlOntology *onto, UString path)
