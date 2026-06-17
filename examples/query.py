"""
This example demonstrates how to load and query an ontology.
"""

from pathlib import Path

import cowl


def main() -> None:
    res_dir = Path(__file__).parent / "res"
    onto = cowl.Ontology.read(res_dir / "pizza.owl")

    # Update the global prefix map for pretty-printing.
    prefix_map = cowl.PrefixMap.default()
    prefix_map.update(onto.prefix_map)

    # Retrieve and print all classes.
    print("Classes:")
    onto.foreach_primitive(print, types=cowl.Class)

    # Retrieve and print all object and data properties in the ontology.
    print("\nProperties:")
    onto.foreach_primitive(print, types=(cowl.ObjectProperty, cowl.DataProperty))

    # Retrieve and print all disjoint classes axioms.
    print("\nDisjoint Classes Axioms:")
    onto.foreach_axiom(print, types=cowl.DisjointClasses)

    # Retrieve and print all axioms referencing the "Margherita" class.
    print("\nAxioms referencing 'Margherita':")
    onto.foreach_axiom(print, primitives=onto.Class("Margherita"))

    # Retrieve and print all class assertions referencing the "Country" class.
    print("\nClass Assertions referencing 'Country':")
    onto.foreach_axiom(print, types=cowl.ClassAssertion, primitives=onto.Class("Country"))

    # Retrieve and print all superclasses of the "CheeseTopping" class.
    print("\nSuperclasses of 'CheeseTopping':")
    cheese_topping = onto.Class("CheeseTopping")
    onto.foreach_related(print, cheese_topping, cowl.SubClassOf, cowl.Position.RIGHT)

    # Retrieve and print all subclasses of the "CheeseTopping" class.
    print("\nSubclasses of 'CheeseTopping':")
    onto.foreach_related(print, cheese_topping, cowl.SubClassOf, cowl.Position.LEFT)

    # Alternative way to carry out the same query.
    print("\nSubclasses of 'CheeseTopping' (alt):")
    onto.foreach_axiom(
        lambda ax: print(ax.child()) if ax.parent() == cheese_topping else None,
        types=cowl.SubClassOf,
        primitives=cheese_topping,
    )

    # Each of the above queries can also return an iterable collection of constructs.
    # We will use this feature to print the toppings of the "Parmense" pizza.
    print("\nToppings of 'Parmense':")

    parmense = onto.Class("Parmense")
    has_topping = onto.ObjectProperty("hasTopping")

    for superclass in onto.related(parmense, cowl.SubClassOf, cowl.Position.RIGHT):
        if not isinstance(superclass, cowl.ObjectSomeValuesFrom):
            continue
        if superclass.property_() == has_topping:
            print(superclass.filler())


if __name__ == "__main__":
    main()
