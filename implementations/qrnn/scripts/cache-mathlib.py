#!/usr/bin/env python3
"""Fetch only the pinned mathlib closure of this project's direct imports."""
import os
from pathlib import Path
import re
import subprocess

project = Path(__file__).resolve().parent.parent
sources = [project / "Qrnn.lean", *sorted((project / "Qrnn").glob("*.lean"))]
modules = sorted({name for source in sources for name in
                  re.findall(r"^import (Mathlib\.[A-Za-z0-9_.]+)$", source.read_text(), re.M)})
environment = os.environ.copy()
environment["MATHLIB_CACHE_DIR"] = str(project / ".cache" / "mathlib")
subprocess.run(["lake", "exe", "cache", "get", *modules], cwd=project,
               env=environment, check=True)
