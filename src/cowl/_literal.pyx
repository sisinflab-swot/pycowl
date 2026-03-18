# type: ignore

from . cimport _factory as factory
from ._c cimport (
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
from ._datatype cimport Datatype
from ._object cimport Object
from ._ptr cimport Ptr


cdef class Literal(Object):

    def __init__(
        self,
        value: str,
        datatype: Datatype | None = None,
        language: str | None = None,
    ) -> None:
        cdef CowlString *c_value = cowl_string_from_py(value)
        cdef CowlDatatype *c_dt = <CowlDatatype *>datatype.ptr() if datatype else NULL
        cdef CowlString *c_lang = cowl_string_from_py(language) if language else NULL
        super().__init__(Ptr.wrap(cowl_literal(c_dt, c_value, c_lang)))
        cowl_release(c_value)
        cowl_release(c_lang)

    def datatype(self) -> Datatype:
        return factory.retain(cowl_literal_get_datatype(<CowlLiteral *>self.ptr()))

    def value(self) -> str:
        return cowl_string_to_py(cowl_literal_get_value(<CowlLiteral *>self.ptr()))

    def language(self) -> str | None:
        cdef CowlString *c_str = cowl_literal_get_lang(<CowlLiteral *>self.ptr())
        return cowl_string_to_py(c_str) if c_str else None
