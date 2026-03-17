from .annotation import Annotation
from .collection import Collection

class Object:
    def get_annotations(self) -> Collection[Annotation]: ...
