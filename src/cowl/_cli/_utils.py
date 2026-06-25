import sys
from collections.abc import Callable, Iterator
from io import BytesIO
from typing import BinaryIO, Literal, overload

import cowl

type InputSource = BinaryIO | str
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


def _input_source(source: str | None, *, seekable: bool) -> InputSource:
    if source is None:
        return BytesIO(sys.stdin.buffer.read()) if seekable else sys.stdin.buffer
    return source


def _reset_source(source: InputSource) -> None:
    if isinstance(source, BytesIO):
        source.seek(0)


def _try_readers[T](
    source: str | None,
    fmt: str | None,
    handler: Callable[[cowl.Reader, InputSource], T],
) -> tuple[cowl.Reader, T]:
    last_error: Exception | None = None
    failed_readers: list[str] = []
    reader: cowl.Reader | None = None
    result: T | None = None
    input_source = _input_source(source, seekable=not fmt)

    for reader in readers(fmt):
        try:
            result = handler(reader, input_source)
        except Exception as exc:
            last_error = exc
            failed_readers.append(reader.name)
            _reset_source(input_source)
        else:
            return reader, result

    msg = "Unable to read ontology."
    if fmt:
        raise RuntimeError(msg) from last_error
    cause_msg = f"Tried readers: {', '.join(failed_readers)}."
    cause = SyntaxError(cause_msg)
    raise RuntimeError(msg) from cause


@overload
def load_ontology(
    source: str | None,
    *,
    fmt: str | None = None,
    return_meta: Literal[False] = False,
) -> cowl.Ontology: ...


@overload
def load_ontology(
    source: str | None,
    *,
    fmt: str | None = None,
    return_meta: Literal[True],
) -> tuple[cowl.Ontology, str, int]: ...


def load_ontology(
    source: str | None,
    *,
    fmt: str | None = None,
    return_meta: bool = False,
) -> cowl.Ontology | tuple[cowl.Ontology, str, int]:
    reader, onto = _try_readers(source, fmt, lambda r, src: r.read(src))
    return (onto, reader.name, reader.read_bytes) if return_meta else onto


def process_ontology(
    source: str | None,
    handler: Callable[[cowl.Change], None],
    fmt: str | None = None,
) -> tuple[str, int]:
    reader, _ = _try_readers(source, fmt, lambda r, src: r.stream(src, handler))
    return reader.name, reader.read_bytes


def print_exc_and_exit(exc: Exception) -> None:
    sys.stderr.write(f"Error: {exc}\n")
    if exc.__cause__:
        sys.stderr.write(f"Cause: {exc.__cause__}\n")
    raise SystemExit(1) from exc
