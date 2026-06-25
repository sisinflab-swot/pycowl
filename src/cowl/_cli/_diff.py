import argparse
import sys
from collections.abc import Iterable

import cowl

from ._utils import load_ontology


class Differ:
    def __init__(
        self,
        *,
        ignore_prefixes: bool = False,
        ignore_iri_version: bool = False,
        ignore_imports: bool = False,
        ignore_annotations: bool = False,
        ignore_axioms: bool = False,
    ) -> None:
        self.changed = False
        self.ignore_prefixes = ignore_prefixes
        self.ignore_iri_version = ignore_iri_version
        self.ignore_imports = ignore_imports
        self.ignore_annotations = ignore_annotations
        self.ignore_axioms = ignore_axioms

    def diff(
        self,
        a: cowl.Ontology,
        b: cowl.Ontology,
    ) -> bool:
        if not self.ignore_prefixes:
            pm_a, pm_b = a.prefix_map, b.prefix_map
            self._diff(pm_a.declarations_iter(), pm_b.declarations_iter())
        if not self.ignore_iri_version:
            self._diff_iri_version(a, b)
        if not self.ignore_imports:
            self._diff(a.imports(), b.imports())
        if not self.ignore_annotations:
            self._diff(a.annotations(), b.annotations())
        if not self.ignore_axioms:
            self._diff(a.axioms(), b.axioms())
        return self.changed

    def _handle_added(self, value: object) -> None:
        self.changed = True
        sys.stdout.write(f"+ {value}\n")

    def _handle_removed(self, value: object) -> None:
        self.changed = True
        sys.stdout.write(f"- {value}\n")

    def _diff_iri_version(self, a: cowl.Ontology, b: cowl.Ontology) -> None:
        for iri_a, iri_b in ((a.iri(), b.iri()), (a.version(), b.version())):
            if iri_a != iri_b:
                if iri_a is not None:
                    self._handle_removed(iri_a)
                if iri_b is not None:
                    self._handle_added(iri_b)

    def _diff(self, first: Iterable[object], second: Iterable[object]) -> None:
        first_str = [str(item) for item in first]
        second_str = [str(item) for item in second]
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


def _diff_sub(args: argparse.Namespace) -> int:
    first = load_ontology(args.reference_path)
    second = load_ontology(args.updated_path)
    default_pm = cowl.PrefixMap.default()
    default_pm.update(first.prefix_map)
    default_pm.update(second.prefix_map)
    differ = Differ(
        ignore_prefixes=args.ignore_prefixes,
        ignore_iri_version=args.ignore_iri,
        ignore_imports=args.ignore_imports,
        ignore_annotations=args.ignore_annotations,
        ignore_axioms=args.ignore_axioms,
    )
    return 1 if differ.diff(first, second) else 0


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
