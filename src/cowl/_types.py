from ._annotation_property import AnnotationProperty
from ._anonymous_individual import AnonymousIndividual
from ._data_property import DataProperty
from ._datatype import Datatype
from ._named_individual import NamedIndividual
from ._object_intersection_of import ObjectIntersectionOf
from ._object_property import ObjectProperty
from ._owlclass import Class
from ._sub_class_of import SubClassOf

type Axiom = SubClassOf
type Entity = (
    Class | Datatype | ObjectProperty | DataProperty | AnnotationProperty | NamedIndividual
)
type Primitive = Entity | AnonymousIndividual
type Individual = NamedIndividual | AnonymousIndividual
type ClassExpression = Class | ObjectIntersectionOf
