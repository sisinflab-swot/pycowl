from ._c cimport CowlAnnotation, cowl_annotation_get_prop, cowl_annotation_get_value

from . cimport _factory as factory
from ._annotation_property cimport AnnotationProperty
from ._object cimport Object


cdef class Annotation(Object):

    def property(self) -> AnnotationProperty:
        cdef CowlAnnotation *annot = <CowlAnnotation *>self.raw_ptr()
        return <AnnotationProperty>factory.retain(<void *>cowl_annotation_get_prop(annot))

    def value(self) -> Object:
        cdef CowlAnnotation *annot = <CowlAnnotation *>self.raw_ptr()
        return factory.retain(<void *>cowl_annotation_get_value(annot))
