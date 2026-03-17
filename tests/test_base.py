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

    def test_ontology(self) -> None:
        """Test ontology parsing, serialization, and querying."""
        orig = cowl.Ontology.at_path(TEST_ONTO_PATH)

        with TemporaryDirectory() as tmp:
            tmp_path = Path(tmp) / "test_onto_out.owl"
            orig.to_path(tmp_path)
            other = cowl.Ontology.at_path(tmp_path)

        assert str(orig) == str(other)

        orig_axioms = set(orig.get_axioms())
        other_axioms = set(other.get_axioms())
        assert orig_axioms == other_axioms


if __name__ == "__main__":
    unittest.main()
