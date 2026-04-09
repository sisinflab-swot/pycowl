"""
This example shows how to use the functional API of PyCowl, comparing it to the fluent API.

The functional API more directly reflects the OWL 2 functional specification, so it is
much more verbose than the fluent API. The fluent API is built on top of the functional API,
which means that both result in the same underlying objects.

Choosing between the two APIs is a matter of preference. The fluent API is more concise and
readable, while the functional API may be more familiar to those who have worked with OWL 2 before.
The functional API may also have slightly lower overhead due to the lower level of abstraction,
but this is unlikely to be significant in most cases.
"""

import cowl


def main() -> None:
    ns = "http://swot.sisinflab.poliba.it/university#"
    adult = cowl.Class(cowl.IRI(ns, "Adult"))
    person = cowl.Class(cowl.IRI(ns, "Person"))
    john_doe = cowl.NamedIndividual(cowl.IRI(ns, "JohnDoe"))
    jane_smith = cowl.NamedIndividual(cowl.IRI(ns, "JaneSmith"))
    has_supervisor = cowl.ObjectProperty(cowl.IRI(ns, "hasSupervisor"))
    has_age = cowl.DataProperty(cowl.IRI(ns, "hasAge"))

    axiom = adult.is_a(person)
    axiom_functional = cowl.SubClassOf(adult, person)
    assert_equal(axiom, axiom_functional)

    axiom = has_supervisor(jane_smith, john_doe)
    axiom_functional = cowl.ObjectPropertyAssertion(has_supervisor, jane_smith, john_doe)
    assert_equal(axiom, axiom_functional)

    axiom = adult.is_a(person.that(has_age.only(cowl.xsd.integer >= 18)))
    axiom_functional = cowl.SubClassOf(
        adult,
        cowl.ObjectIntersectionOf(
            person,
            cowl.DataAllValuesFrom(
                has_age,
                cowl.DatatypeRestriction(
                    cowl.xsd.integer,
                    cowl.FacetRestriction(
                        cowl.xsd.min_inclusive,
                        cowl.Literal("18", cowl.xsd.integer),
                    ),
                ),
            ),
        ),
    )
    assert_equal(axiom, axiom_functional)


def assert_equal(a: cowl.Axiom, b: cowl.Axiom) -> None:
    if a == b:
        print("The two axioms are equivalent.")
    else:
        print("Uh-oh.")


if __name__ == "__main__":
    main()
