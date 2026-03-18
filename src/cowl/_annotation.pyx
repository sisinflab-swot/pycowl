# type: ignore

from ._c cimport CowlAnnotation, cowl_annotation_get_prop, cowl_annotation_get_value

from . cimport _factory as factory
from ._annotation_property cimport AnnotationProperty
from ._object cimport Object


cdef class Annotation(Object):

    def property(self) -> AnnotationProperty:
        return factory.retain(cowl_annotation_get_prop(<CowlAnnotation *>self.ptr()))

    def value(self) -> Object:
        return factory.retain(cowl_annotation_get_value(<CowlAnnotation *>self.ptr()))
