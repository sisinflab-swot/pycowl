"""Setup script for building the Cowl Python bindings."""

import os
import shutil
import subprocess
import sys
from collections.abc import Iterable, Iterator
from pathlib import Path
from typing import cast

from Cython.Build import cythonize  # pyright: ignore[reportUnknownVariableType]
from setuptools import Extension, setup

# User config

BUILD_TYPE = os.environ.get("COWL_BUILD_TYPE", "Release")
ENTITY_IDS = os.environ.get("COWL_ENTITY_IDS", "OFF")

# Paths

ROOT_DIR = Path()
NATIVE_LIB_DIR = ROOT_DIR / "lib" / "cowl"
NATIVE_BUILD_DIR = NATIVE_LIB_DIR / "build"
NATIVE_INCLUDE_DIRS = [NATIVE_LIB_DIR / "include", NATIVE_LIB_DIR / "lib" / "ulib" / "include"]
BUILD_DIR = ROOT_DIR / "build"
SRC_DIR = ROOT_DIR / "src"
PKG_DIR = SRC_DIR / "cowl"

# Build config

if sys.platform == "win32":
    CONFIG_ARGS: list[str] = ["-A", "x64"]
    BUILD_ARGS: list[str] = ["--config", BUILD_TYPE]
    RPATH_LIBS = []
else:
    CONFIG_ARGS: list[str] = []
    BUILD_ARGS: list[str] = ["--parallel"]
    if sys.platform == "darwin":
        RPATH_LIBS = ["@loader_path"]
    else:
        RPATH_LIBS = ["$ORIGIN"]


SHARED_LIB_GLOBS = ("*.so", "*.dylib", "*.dll")
IMPORT_LIB_GLOBS = ("*.so", "*.dylib", "*.lib")

NATIVE_DEFINES = [
    ("COWL_BUILDING", "1"),
    ("COWL_DEFAULT_READER", "functional"),
    ("COWL_DEFAULT_WRITER", "functional"),
    ("COWL_READER_FUNCTIONAL", "1"),
    ("COWL_WRITER_FUNCTIONAL", "1"),
    ("COWL_ENTITY_IDS", "1" if ENTITY_IDS.upper() == "ON" else "0"),
]


# Build logic


def find(directory: Path, globs: str | Iterable[str]) -> Iterator[Path]:
    """Find files in a directory with specific extensions."""
    if isinstance(globs, str):
        globs = (globs,)
    for glob in globs:
        yield from directory.rglob(glob)


def rm(*args: Path) -> None:
    """Remove files or directories."""
    for path in args:
        if path.is_dir():
            shutil.rmtree(path, ignore_errors=True)
        elif path.is_file():
            path.unlink()


def cp(src: Path, dst: Path) -> None:
    """Copy a file or directory."""
    if src.is_dir():
        shutil.copytree(src, dst, dirs_exist_ok=True)
    else:
        shutil.copy(src, dst)


def cmake(*args: str) -> None:
    """Run a CMake command."""
    subprocess.run(["cmake", *args], check=True)  # noqa: S603, S607


def configure() -> None:
    """Configure the build using CMake."""
    cmake(
        *CONFIG_ARGS,
        "-B",
        str(NATIVE_BUILD_DIR),
        f"-DCMAKE_BUILD_TYPE={BUILD_TYPE}",
        "-DCOWL_LTO=OFF",
        "-DCOWL_LIBRARY_TYPE=SHARED",
        f"-DCOWL_ENTITY_IDS={ENTITY_IDS}",
        "-DULIB_LIBRARY_TYPE=SHARED",
        "-DULIB_LTO=OFF",
        str(NATIVE_LIB_DIR),
    )


def build() -> None:
    """Compile the native library."""
    cmake(
        "--build",
        str(NATIVE_BUILD_DIR),
        *BUILD_ARGS,
        "--target",
        "cowl",
    )
    for lib_path in find(NATIVE_BUILD_DIR, SHARED_LIB_GLOBS):
        cp(lib_path, PKG_DIR)


def clean() -> None:
    """Clean up build artifacts."""
    rm(BUILD_DIR, NATIVE_BUILD_DIR, PKG_DIR.with_suffix(".egg-info"))
    rm(*find(PKG_DIR, ("*.c", *SHARED_LIB_GLOBS)))
    rm(*find(ROOT_DIR, "__pycache__"))


def build_native_libs() -> None:
    """Build the native libraries."""
    try:
        configure()
        build()
    except Exception:
        clean()


def extensions() -> list[Extension]:
    """Cython extensions to build."""
    import_libs = [str(p) for p in find(NATIVE_BUILD_DIR, IMPORT_LIB_GLOBS)]
    include_dirs = [str(p) for p in NATIVE_INCLUDE_DIRS]
    lib_dirs = [str(PKG_DIR)]
    defines = cast("list[tuple[str, str | None]]", NATIVE_DEFINES)
    return [
        Extension(
            name=f"cowl.{source.stem}",
            sources=[source],
            define_macros=defines,
            include_dirs=include_dirs,
            library_dirs=lib_dirs,
            runtime_library_dirs=RPATH_LIBS,
            extra_objects=import_libs,
            language="c",
        )
        for source in PKG_DIR.glob("*.pyx")
    ]


def setup_package() -> None:
    """Run the setup process."""
    opts = {"language_level": 3}
    exts = cast("list[Extension]", cythonize(extensions(), compiler_directives=opts))
    setup(ext_modules=exts)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "clean":
        clean()
    else:
        build_native_libs()
        setup_package()
