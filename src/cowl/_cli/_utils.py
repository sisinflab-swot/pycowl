import sys
from collections.abc import Callable, Iterator

import cowl

SUPPORTED_FORMATS = ("functional", "protocowl")


def readers(fmt: str | None = None) -> Iterator[cowl.Reader]:
    if fmt == "functional":
        yield cowl.Reader.functional()
    elif fmt == "protocowl":
        yield cowl.Reader.protocowl()
    else:
        yield cowl.Reader.functional()
        yield cowl.Reader.protocowl()


def writer(
    fmt: str | None,
    *,
    index_size: int = -1,
    encode_anonymous_individuals: bool = True,
) -> cowl.Writer:
    if fmt == "functional":
        return cowl.Writer.functional()
    return cowl.Writer.protocowl(
        index_size=index_size,
        encode_anonymous_individuals=encode_anonymous_individuals,
    )


def load_ontology(source: str | None, fmt: str | None = None) -> cowl.Ontology:
    last_error: Exception | None = None
    source_stream = sys.stdin.buffer if source is None else source
    onto: cowl.Ontology | None = None

    for reader in readers(fmt):
        try:
            onto = reader.read(source_stream)
        except Exception as exc:
            last_error = exc
        else:
            last_error = None
            break

    if not onto:
        msg = "Unable to read ontology."
        raise RuntimeError(msg) from last_error

    return onto


def process_ontology(
    source: str | None,
    handler: Callable[[cowl.Change], None],
    fmt: str | None = None,
) -> None:
    last_error: Exception | None = None
    source_stream = sys.stdin.buffer if source is None else source

    for reader in readers(fmt):
        try:
            reader.stream(source_stream, handler)
        except Exception as exc:
            last_error = exc
        else:
            last_error = None
            break

    if last_error:
        msg = "Unable to read ontology."
        raise RuntimeError(msg) from last_error


def print_exc_and_exit(exc: Exception) -> None:
    sys.stderr.write(f"Error: {exc}\n")
    if exc.__cause__:
        sys.stderr.write(f"Cause: {exc.__cause__}\n")
    raise SystemExit(1) from exc
