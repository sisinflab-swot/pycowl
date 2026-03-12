"""Exported symbols."""

from . import c as c  # Trigger native library initialization.
from .ontology import Ontology

__all__ = ["Ontology"]
