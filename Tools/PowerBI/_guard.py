"""Safety checks shared by pbir.py and tmdl.py.

The committed PBIR/TMDL files are the source of truth for the samples. These checks stop the helpers from
overwriting files that have uncommitted changes (e.g. an unsaved-to-git Power BI Desktop save).
"""
from __future__ import annotations

import subprocess
from pathlib import Path


def require_clean(path: Path, allow_dirty: bool = False):
    """Raise if git reports uncommitted changes under path. Skipped (with a warning) outside a git work tree."""
    if allow_dirty:
        return
    path = Path(path).resolve()
    cwd = path if path.is_dir() else path.parent
    try:
        result = subprocess.run(["git", "status", "--porcelain", "--", str(path)], cwd=cwd,
                                capture_output=True, text=True, check=True)
    except (OSError, subprocess.CalledProcessError):
        print(f"warning: could not check git status for {path}; continuing without the uncommitted-changes guard")
        return
    if result.stdout.strip():
        raise RuntimeError(
            f"{path} has uncommitted changes:\n{result.stdout}"
            "Commit them first (they may be Power BI Desktop or manual edits), or pass allow_dirty=True "
            "if you are sure they can be overwritten.")
