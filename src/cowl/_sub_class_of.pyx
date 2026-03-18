# type: ignore

from typing import Iterable
from . cimport _factory as factory
from ._c cimport (
    CowlSubClsAxiom,
    CowlVector,
    cowl_release,
    cowl_sub_cls_axiom,
    cowl_sub_cls_axiom_get_sub,
    cowl_sub_cls_axiom_get_super,
    cowl_vector_from_py,
)
from ._object cimport Object
from ._ptr cimport Ptr


cdef class SubClassOf(Object):

    def __init__(self,
        sub_class: Object,
        super_class: Object,
        annotations: Iterable[Annotation] | None = None,
    ) -> None:
        cdef CowlVector *annot = NULL if annotations is None else cowl_vector_from_py(annotations)
        cdef void *ax = cowl_sub_cls_axiom(sub_class.ptr(), super_class.ptr(), annot)
        super().__init__(Ptr.wrap(ax))
        cowl_release(annot)

    def sub_class(self) -> Object:
        return factory.retain(cowl_sub_cls_axiom_get_sub(<CowlSubClsAxiom *>self.ptr()))

    def super_class(self) -> Object:
        return factory.retain(cowl_sub_cls_axiom_get_super(<CowlSubClsAxiom *>self.ptr()))
