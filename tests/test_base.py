import unittest
from pathlib import Path

import cowl

TEST_DIR = Path(__file__).parent
RES_DIR = TEST_DIR / "res"


class BasicTest(unittest.TestCase):
    """Tests if the library is installed and can be imported."""

    def test_print(self) -> None:
        """Test if the library can be imported and used."""
        ontology = cowl.Ontology.at_path(RES_DIR / "test_onto.owl")
        print(ontology.as_string())


if __name__ == "__main__":
    unittest.main()
