import cowl


def test_iri() -> None:
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


def test_literal() -> None:
    value = "Hello, world!"
    lang = "en"

    lit_a = cowl.Literal(value)
    lit_b = cowl.Literal(value, datatype=cowl.xsd.string)
    lit_c = cowl.Literal(value, language=lang)

    assert lit_a == lit_b
    assert lit_a.value() == lit_b.value() == lit_c.value() == value
    assert lit_a.datatype() == lit_b.datatype() == cowl.xsd.string
    assert lit_c.datatype() == cowl.rdf.lang_string
    assert lit_a.language() is lit_b.language() is None
    assert lit_c.language() == lang
