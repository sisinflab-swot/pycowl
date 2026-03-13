"""Tests for the base functionality of the library."""

import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import cowl

TEST_DIR = Path(__file__).parent
RES_DIR = TEST_DIR / "res"
TEST_ONTO_PATH = RES_DIR / "test_onto.owl"


class BasicTest(unittest.TestCase):
    """Tests if the library is installed and can be imported."""

    def test_print(self) -> None:
        """Test if the library can be imported and used."""
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
