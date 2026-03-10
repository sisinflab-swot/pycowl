"""Setup script for building the Cowl Python bindings."""

import os
import shutil
import subprocess
import sys
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
PKG_DIR = ROOT_DIR / "src" / "cowl"

# Build config

if sys.platform == "win32":
    CONFIG_ARGS: list[str] = ["-A", "x64"]
    BUILD_ARGS: list[str] = ["--config", BUILD_TYPE]
else:
    CONFIG_ARGS: list[str] = []
    BUILD_ARGS: list[str] = ["--parallel"]


SHARED_LIB_EXTS = {".so", ".dylib", ".dll"}
IMPORT_LIB_EXTS = {".so", ".dylib", ".lib"}

NATIVE_DEFINES = [
    ("COWL_BUILDING", "1"),
    ("COWL_DEFAULT_READER", "functional"),
    ("COWL_DEFAULT_WRITER", "functional"),
    ("COWL_READER_FUNCTIONAL", "1"),
    ("COWL_WRITER_FUNCTIONAL", "1"),
    ("COWL_ENTITY_IDS", "1" if ENTITY_IDS.upper() == "ON" else "0"),
]


# Build logic


def find(directory: Path, exts: set[str]) -> list[Path]:
    """Find files in a directory with specific extensions."""
    return [p for p in directory.rglob("*") if p.suffix.lower() in exts]


def import_libs() -> list[Path]:
    """Find the paths to the import libraries."""
    return find(NATIVE_BUILD_DIR, IMPORT_LIB_EXTS)


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
    for lib_path in find(NATIVE_BUILD_DIR, SHARED_LIB_EXTS):
        lib_path.copy_into(PKG_DIR)


def clean() -> None:
    """Clean up build artifacts."""
    for dir_path in (NATIVE_BUILD_DIR, BUILD_DIR):
        shutil.rmtree(dir_path, ignore_errors=True)

    for path in find(PKG_DIR, SHARED_LIB_EXTS.union({".c"})):
        path.unlink()


def build_native_libs() -> None:
    """Build the native libraries."""
    try:
        configure()
        build()
    except Exception:
        clean()


def extensions() -> list[Extension]:
    """Cython extensions to build."""
    import_libs = [str(p) for p in find(NATIVE_BUILD_DIR, IMPORT_LIB_EXTS)]
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
