import argparse
import sys

import cowl

from ._utils import SUPPORTED_FORMATS, process_ontology, writer as get_writer


class _ChangeHandler:
    def __init__(self, writer: cowl.StreamWriter) -> None:
        self.header_ontology = cowl.Ontology()
        self.header_written = False
        self.writer = writer

    def __call__(self, change: cowl.Change) -> None:
        if isinstance(change.value, cowl.Axiom):
            if not self.header_written:
                self.writer.write(cowl.Header.from_ontology(self.header_ontology))
                self.header_written = True
            self.writer.write(change.value)
        else:
            self.header_ontology.change(change)


def _convert_sub(args: argparse.Namespace) -> int:
    dest = sys.stdout.buffer if args.output_path is None else args.output_path

    writer = get_writer(
        args.destination_format,
        index_size=args.index_size,
        encode_anonymous_individuals=not args.fresh_anonymous_individuals,
    )

    with writer.stream(dest) as stream_writer:
        process_ontology(
            args.input_path,
            _ChangeHandler(stream_writer),
            fmt=args.source_format,
        )

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
        "-d",
        "--destination-format",
        choices=SUPPORTED_FORMATS,
        required=True,
        help="Output format.",
    )
    parser.add_argument(
        "-o",
        "--output-path",
        help="Output path. If omitted, data is written to stdout.",
    )
    parser.set_defaults(func=_convert_sub)

    protocowl_group = parser.add_argument_group("ProtocOWL options")
    protocowl_group.add_argument(
        "--fresh-anonymous-individuals",
        action="store_false",
        help="Generate fresh individuals IDs, reducing output size.",
    )
    protocowl_group.add_argument(
        "--index-size",
        type=int,
        default=-1,
        help="Set the index size. If negative, the index is unbounded.",
    )
