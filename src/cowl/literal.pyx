from . cimport factory
from .c cimport (
    CowlDatatype,
    CowlLiteral,
    CowlString,
    cowl_literal,
    cowl_literal_get_datatype,
    cowl_literal_get_lang,
    cowl_literal_get_value,
    cowl_release,
    cowl_string_from_py,
    cowl_string_to_py,
)
from .datatype cimport Datatype
from .object cimport Object
from .ptr cimport Ptr


cdef class Literal(Object):

    def __init__(
        self,
        value: str,
        datatype: Datatype | None = None,
        language: str | None = None,
    ) -> None:
        cdef CowlString *c_value = cowl_string_from_py(value)
        cdef CowlDatatype *c_dt
        c_dt = <CowlDatatype *>datatype.raw_ptr() if datatype else <CowlDatatype *>NULL
        cdef CowlString *c_lang = cowl_string_from_py(language) if language else <CowlString *>NULL
        super().__init__(Ptr.wrap(<void *>cowl_literal(c_dt, c_value, c_lang)))
        cowl_release(<void *>c_value)
        cowl_release(<void *>c_lang)

    def datatype(self) -> Datatype:
        cdef void *ptr = <void *>cowl_literal_get_datatype(<CowlLiteral *>self.raw_ptr())
        return <Datatype>factory.retain(ptr)

    def value(self) -> str:
        cdef CowlString *c_str = cowl_literal_get_value(<CowlLiteral *>self.raw_ptr())
        return cowl_string_to_py(c_str)

    def language(self) -> str | None:
        cdef CowlString *c_str = cowl_literal_get_lang(<CowlLiteral *>self.raw_ptr())
        return cowl_string_to_py(c_str) if c_str else None
