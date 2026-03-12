"""Tests for the base functionality of the library."""

import unittest
from pathlib import Path

import cowl

TEST_DIR = Path(__file__).parent
RES_DIR = TEST_DIR / "res"
TEST_ONTO_PATH = RES_DIR / "test_onto.owl"
TEST_ONTO_OUT_PATH = TEST_DIR / "test_onto_out.owl"


class BasicTest(unittest.TestCase):
    """Tests if the library is installed and can be imported."""

    def test_print(self) -> None:
        """Test if the library can be imported and used."""
        orig = cowl.Ontology.at_path(TEST_ONTO_PATH)
        orig.to_path(TEST_ONTO_OUT_PATH)
        other = cowl.Ontology.at_path(TEST_ONTO_OUT_PATH)
        assert str(orig) == str(other)


if __name__ == "__main__":
    unittest.main()
