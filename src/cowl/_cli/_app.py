import argparse
import sys

from ._convert import add_args as convert_args
from ._diff import add_args as diff_args
from ._stats import add_args as stats_args
from ._utils import print_exc_and_exit


def _main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)

    convert_parser = subparsers.add_parser(
        "convert",
        help="Convert an ontology between supported formats.",
    )
    convert_args(convert_parser)

    diff_parser = subparsers.add_parser(
        "diff",
        help="Show changes between two ontologies.",
    )
    diff_args(diff_parser)

    stats_parser = subparsers.add_parser(
        "stats",
        help="Displays basic statistics about an ontology.",
    )
    stats_args(stats_parser)

    args = parser.parse_args()
    return args.func(args)


def app() -> None:
    try:
        sys.exit(_main())
    except Exception as exc:
        print_exc_and_exit(exc)
