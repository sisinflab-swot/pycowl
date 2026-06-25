"""
This example demonstrates how to use readers and writers to read and write ontologies
in different formats and using different parsing and serialization techniques.
"""

import sys
from pathlib import Path

import cowl


def main() -> None:
    # Read the ontology in Functional syntax.
    res_dir = Path(__file__).parent / "res"
    onto = cowl.Reader.functional().read(res_dir / "pizza.owl")
    cowl.PrefixMap.default().update(onto.prefix_map)  # For pretty printing.

    # Write the ontology in ProtocOWL format.
    cowl.Writer.protocowl().write(onto, res_dir / "pizza.oprt")

    # Read the ontology back in ProtocOWL format and print its annotations using the streaming API.
    print("Ontology annotations:")
    cowl.Reader.protocowl().stream(
        res_dir / "pizza.oprt",
        lambda c: print(c.value) if isinstance(c.value, cowl.Annotation) else None,
    )

    # Print the sub-ontology about the :Pizza class in Functional syntax using the streaming API.
    print("\nSub-ontology about :Pizza:", flush=True)
    with cowl.Writer.functional().stream(sys.stdout.buffer) as stream_writer:
        stream_writer.write(cowl.Header(prefix_map=onto.prefix_map))
        for axiom in onto.axioms(primitives=onto.Class("Pizza")):
            stream_writer.write(axiom)


if __name__ == "__main__":
    main()
