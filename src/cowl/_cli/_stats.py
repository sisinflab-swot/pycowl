import argparse
import json
import sys
from collections.abc import Iterator
from pathlib import Path

import cowl

from ._utils import SUPPORTED_FORMATS, load_ontology


def _axiom_types(axiom_type: type[cowl.Axiom] = cowl.Axiom) -> Iterator[type[cowl.Axiom]]:
    for sub_type in axiom_type.__subclasses__():
        if sub_type.__subclasses__():
            yield from _axiom_types(sub_type)
        else:
            yield sub_type


def _compute_stats(onto: cowl.Ontology) -> dict[str, int]:
    stats = {
        "Axioms": onto.axiom_count(),
        "Classes": onto.primitive_count(cowl.Class),
        "Datatypes": onto.primitive_count(cowl.Datatype),
        "Named individuals": onto.primitive_count(cowl.NamedIndividual),
        "Anonymous individuals": onto.primitive_count(cowl.AnonymousIndividual),
        "Object properties": onto.primitive_count(cowl.ObjectProperty),
        "Data properties": onto.primitive_count(cowl.DataProperty),
        "Annotation properties": onto.primitive_count(cowl.AnnotationProperty),
    }
    for axiom_type in _axiom_types():
        stats[f"{axiom_type.__name__} axioms"] = onto.axiom_count(axiom_type)
    return stats


def _stats_sub(args: argparse.Namespace) -> int:
    stats = _compute_stats(load_ontology(args.input_path, fmt=args.source_format))

    with Path(args.output_path).open("w") if args.output_path else sys.stdout as out_file:
        json.dump(stats, out_file, indent=4)
        out_file.write("\n")

    return 0


def add_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "input_path",
        nargs="?",
        help="Input path. If omitted, data is read from stdin.",
    )
    parser.add_argument(
        "-s",
        "--source-format",
        choices=SUPPORTED_FORMATS,
        help="Input format. If omitted, all formats are tried.",
    )
    parser.add_argument(
        "-o",
        "--output",
        dest="output_path",
        type=str,
        help="Output path. If omitted, data is written to stdout.",
    )
    parser.set_defaults(func=_stats_sub)
