import argparse
import sys
from collections.abc import Callable, Collection
from typing import Any

import cowl

from ._utils import load_ontology


def _format_prefix_decl(value: tuple[str, str]) -> str:
    prefix, namespace = value
    return f"Prefix({prefix}:=<{namespace}>)"


def _write_added(value: object) -> None:
    sys.stdout.write(f"+ {value}\n")


def _write_removed(value: object) -> None:
    sys.stdout.write(f"- {value}\n")


class _Differ:
    def __init__(self, formatter: Callable[[Any], str] = str) -> None:
        self.changed = False
        self._formatter = formatter

    def _handle_added(self, value: object) -> None:
        self.changed = True
        _write_added(value)

    def _handle_removed(self, value: object) -> None:
        self.changed = True
        _write_removed(value)

    def diff(
        self,
        first: Collection[object],
        second: Collection[object],
    ) -> bool:
        self.changed = False

        first_str = [self._formatter(item) for item in first]
        second_str = [self._formatter(item) for item in second]
        first_str.sort()
        second_str.sort()

        i = 0
        j = 0

        while i < len(first_str) and j < len(second_str):
            first_item = first_str[i]
            second_item = second_str[j]

            if first_item == second_item:
                i += 1
                j += 1
                continue

            if first_item < second_item:
                self._handle_removed(first_item)
                i += 1
            else:
                self._handle_added(second_item)
                j += 1

        for item in first_str[i:]:
            self._handle_removed(item)

        for item in second_str[j:]:
            self._handle_added(item)

        return self.changed


def _diff_prefixes(first: cowl.Ontology, second: cowl.Ontology) -> bool:
    first_prefixes = list(first.prefix_map.items())
    second_prefixes = list(second.prefix_map.items())
    return _Differ(formatter=_format_prefix_decl).diff(first_prefixes, second_prefixes)


def _diff_collections(first: Collection[object], second: Collection[object]) -> bool:
    return _Differ().diff(first, second)


def _diff_iri_version(first: cowl.Ontology, second: cowl.Ontology) -> bool:
    changed = False
    for first_iri, second_iri in ((first.iri(), second.iri()), (first.version(), second.version())):
        if first_iri != second_iri:
            if first_iri is not None:
                changed = True
                _write_removed(first_iri)
            if second_iri is not None:
                changed = True
                _write_added(second_iri)
    return changed


def _diff_ontologies(
    first: cowl.Ontology,
    second: cowl.Ontology,
    *,
    ignore_prefixes: bool = False,
    ignore_iri_version: bool = False,
    ignore_imports: bool = False,
    ignore_annotations: bool = False,
    ignore_axioms: bool = False,
) -> bool:
    changed = False
    if not ignore_prefixes:
        changed |= _diff_prefixes(first, second)
    if not ignore_iri_version:
        changed |= _diff_iri_version(first, second)
    if not ignore_imports:
        changed |= _diff_collections(first.imports(), second.imports())
    if not ignore_annotations:
        changed |= _diff_collections(first.annotations(), second.annotations())
    if not ignore_axioms:
        changed |= _diff_collections(first.axioms(), second.axioms())
    return changed


def _diff_sub(args: argparse.Namespace) -> int:
    first = load_ontology(args.reference_path)
    second = load_ontology(args.updated_path)
    default_pm = cowl.PrefixMap.default()
    default_pm.update(first.prefix_map)
    default_pm.update(second.prefix_map)
    changed = _diff_ontologies(
        first,
        second,
        ignore_prefixes=args.ignore_prefixes,
        ignore_iri_version=args.ignore_iri,
        ignore_imports=args.ignore_imports,
        ignore_annotations=args.ignore_annotations,
        ignore_axioms=args.ignore_axioms,
    )
    return 1 if changed else 0


def add_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "reference_path",
        help="Path to the reference ontology.",
    )
    parser.add_argument(
        "updated_path",
        help="Path to the updated ontology.",
    )
    parser.add_argument(
        "--ignore-prefixes",
        action="store_true",
        help="Ignore differences in prefix declarations.",
    )
    parser.add_argument(
        "--ignore-iri",
        action="store_true",
        help="Ignore differences in ontology IRI and version IRI.",
    )
    parser.add_argument(
        "--ignore-imports",
        action="store_true",
        help="Ignore differences in ontology imports.",
    )
    parser.add_argument(
        "--ignore-annotations",
        action="store_true",
        help="Ignore differences in ontology annotations.",
    )
    parser.add_argument(
        "--ignore-axioms",
        action="store_true",
        help="Ignore differences in ontology axioms.",
    )
    parser.set_defaults(func=_diff_sub)
