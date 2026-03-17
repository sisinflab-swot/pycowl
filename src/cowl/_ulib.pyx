from ._ulib cimport (
    UStrBuf,
    UString,
    ustrbuf_data,
    ustrbuf_deinit,
    ustrbuf_length,
    ustring_copy,
    ustring_data,
    ustring_deinit,
    ustring_length,
)


cdef UString ustring_from_py(str pystr):
    encoded = pystr.encode("utf-8")
    return ustring_copy(<const char *>encoded, len(pystr))


cdef str ustring_to_py(UString *ustr, bool deinit = True):
    cdef UString val = ustr[0]
    try:
        ret: str = ustring_data(val)[:ustring_length(val)].decode("utf-8")
    finally:
        if deinit:
            ustring_deinit(ustr)
    return ret

cdef str ustrbuf_to_py(UStrBuf *buf, bool deinit = True):
    try:
        ret: str = ustrbuf_data(buf)[:ustrbuf_length(buf)].decode("utf-8")
    finally:
        if deinit:
            ustrbuf_deinit(buf)
    return ret
