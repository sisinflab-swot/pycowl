cdef extern from "ulib.h":

    ctypedef int ulib_ret

    cpdef enum ulib_ret_builtin:
        ULIB_OK
        ULIB_NO
        ULIB_ERR
        ULIB_ERR_MEM
        ULIB_ERR_BOUNDS
        ULIB_ERR_IO

    ctypedef struct UString:
        pass

    ctypedef struct UStrBuf:
        pass

    ctypedef struct UOStream:
        pass

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

    ulib_ret uostream_to_strbuf(UOStream *stream, UStrBuf *buf)
    ulib_ret uostream_deinit(UOStream *stream)

cdef UString ustring_from_py(str pystr)
cdef str ustring_to_py(UString *str, bool deinit = *)
cdef str ustrbuf_to_py(UStrBuf *buf, bool deinit = *)
