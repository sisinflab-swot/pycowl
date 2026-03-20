import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import cowl

TEST_DIR = Path(__file__).parent
RES_DIR = TEST_DIR / "res"
TEST_ONTO_PATH = RES_DIR / "test_onto.owl"


class BasicTest(unittest.TestCase):
    def test_iri(self) -> None:
        ns = "http://example.org/test#"
        rem = "MyClass"
        iri_str = ns + rem

        iri_a = cowl.IRI(iri_str)
        iri_b = cowl.IRI(ns, rem)

        assert iri_a == iri_b
        assert str(iri_a) == str(iri_b)
        assert iri_a.namespace() == iri_b.namespace() == ns
        assert iri_a.remainder() == iri_b.remainder() == rem
        assert iri_a.as_string() == iri_b.as_string() == iri_str

    def test_literal(self) -> None:
        value = "Hello, world!"
        lang = "en"
        dt = cowl.Datatype("http://www.w3.org/2001/XMLSchema#string")
        lang_dt = cowl.Datatype("http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")

        lit_a = cowl.Literal(value)
        lit_b = cowl.Literal(value, datatype=dt)
        lit_c = cowl.Literal(value, language=lang)

        assert lit_a == lit_b
        assert lit_a.value() == lit_b.value() == lit_c.value() == value
        assert lit_a.datatype() == lit_b.datatype() == dt
        assert lit_c.datatype() == lang_dt
        assert lit_a.language() is lit_b.language() is None
        assert lit_c.language() == lang

    def test_parse_serialize(self) -> None:
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

        orig_primitives = set(orig.primitives())
        other_primitives = set(other.primitives())
        assert orig_primitives == other_primitives

    def test_edit(self) -> None:
        iri = "http://example.org/test"
        ns = iri + "#"

        onto = cowl.Ontology()
        onto.set_iri(iri, update_prefix=True)

        a = cowl.Class(ns + "A")
        b = cowl.Class(ns + "B")
        c = cowl.Class(ns + "C")
        d = cowl.Class(ns + "D")
        prop = cowl.ObjectProperty(ns + "prop")
        ind = cowl.NamedIndividual(ns + "ind")

        axioms: tuple[cowl.Axiom, ...] = (
            a.is_a(b | (c & d)),
            ind.is_a(prop.all(c) & prop.some(c)),
        )

        onto.add(*axioms)

        for axiom in axioms:
            assert axiom in onto
            assert axiom in onto.axioms()

        onto.remove(*axioms)

        for axiom in axioms:
            assert axiom not in onto
            assert axiom not in onto.axioms()


if __name__ == "__main__":
    unittest.main()
