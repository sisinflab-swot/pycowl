import ctypes
import sys
from pathlib import Path


def _load_shared_libs() -> None:
    pkg_dir = Path(__file__).parent

    if sys.platform == "darwin":
        libs = ["libcowl.dylib", "ulib.dylib"]
    elif sys.platform == "win32":
        libs = ["cowl.dll", "ulib.dll"]
    else:
        libs = ["libcowl.so", "ulib.so"]

    for lib in libs:
        ctypes.cdll.LoadLibrary(str(pkg_dir / lib))


_load_shared_libs()
