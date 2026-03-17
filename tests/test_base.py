"""Tests for the base functionality of the library."""

import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import cowl

TEST_DIR = Path(__file__).parent
RES_DIR = TEST_DIR / "res"
TEST_ONTO_PATH = RES_DIR / "test_onto.owl"


class BasicTest(unittest.TestCase):
    """Basic data model tests."""

    def test_iri(self) -> None:
        """IRI tests."""
        ns = "http://example.org/test#"
        rem = "MyClass"
        iri_str = ns + rem

        iri_a = cowl.IRI(iri_str)
        iri_b = cowl.IRI(ns, rem)

        assert iri_a.namespace() == iri_b.namespace() == ns
        assert iri_a.remainder() == iri_b.remainder() == rem
        assert str(iri_a) == str(iri_b) == iri_str

    def test_literal(self) -> None:
        """Literal tests."""
        value = "Hello, world!"
        lang = "en"
        dt = cowl.Datatype("http://www.w3.org/2001/XMLSchema#string")
        lang_dt = cowl.Datatype("http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")

        lit_a = cowl.Literal(value)
        lit_b = cowl.Literal(value, datatype=dt)
        lit_c = cowl.Literal(value, language=lang)

        assert lit_a.value() == lit_b.value() == lit_c.value() == value
        assert lit_a.datatype() == lit_b.datatype() == dt
        assert lit_c.datatype() == lang_dt
        assert lit_a.language() == lit_b.language() == None
        assert lit_c.language() == lang

    def test_ontology(self) -> None:
        """Test ontology parsing, serialization, and querying."""
        orig = cowl.Ontology.at_path(TEST_ONTO_PATH)

        with TemporaryDirectory() as tmp:
            tmp_path = Path(tmp) / "test_onto_out.owl"
            orig.to_path(tmp_path)
            other = cowl.Ontology.at_path(tmp_path)

        assert str(orig) == str(other)
        assert orig.iri() == other.iri()

        orig_axioms = set(orig.axioms())
        other_axioms = set(other.axioms())
        assert orig_axioms == other_axioms

        orig_annotations = set(orig.annotations())
        other_annotations = set(other.annotations())
        assert orig_annotations == other_annotations


if __name__ == "__main__":
    unittest.main()
