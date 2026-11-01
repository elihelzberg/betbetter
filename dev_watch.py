"""Project-local workaround for Jac 0.37.23 watching nested dependencies.

That release filters node_modules directory events but still processes events
for files inside it. The Expo app is independent of the desktop client, so its
entire tree must not trigger desktop HMR. Keep this shim until Jac filters
nested dependency trees itself.
"""
from functools import wraps
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
IGNORED_PARTS = frozenset({"node_modules", ".git", ".venv", "venv", "__pycache__", ".expo", ".jac"})


def should_ignore_change(path: str, project_root: Path = PROJECT_ROOT) -> bool:
    """Ignore generated/dependency trees and the independent Expo app."""
    candidate = Path(path)
    try:
        relative = candidate.relative_to(project_root)
    except ValueError:
        return False
    return bool(relative.parts) and (
        relative.parts[0] == "mobile"
        or any(part in IGNORED_PARTS for part in relative.parts)
    )


def install_dev_watch_filter() -> None:
    """Filter before debounce/rebuild; repeated startup imports are harmless."""
    from jaclang.server.watcher import JacFileWatcher

    original = JacFileWatcher._on_change
    if getattr(original, "_betbetter_filter", False):
        return

    @wraps(original)
    def on_change(self, path, change_type, is_directory=False):
        if should_ignore_change(path):
            return
        return original(self, path, change_type, is_directory)

    on_change._betbetter_filter = True
    JacFileWatcher._on_change = on_change
