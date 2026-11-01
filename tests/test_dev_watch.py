"""Desktop HMR must react to app edits, never the nested Expo toolchain."""
import sys
import types
import unittest
from unittest.mock import patch
from pathlib import Path

from dev_watch import install_dev_watch_filter, should_ignore_change


class DevWatchTests(unittest.TestCase):
    def test_independent_mobile_and_nested_dependencies_are_ignored(self):
        root = Path('/project')
        for path in (
            'mobile/src/app/index.tsx',
            'mobile/node_modules/expo-router/build/index.js',
            'other/node_modules/package/index.js',
            '.venv/lib/package/module.py',
            '.jac/client/compiled/frontend.js',
            'mobile',
        ):
            with self.subTest(path=path):
                self.assertTrue(should_ignore_change(str(root / path), root))

    def test_desktop_sources_and_assets_still_reload(self):
        root = Path('/project')
        for path in ('frontend.jac', 'components/Styles.jac', 'assets/logo.png', 'mobile_api.jac'):
            with self.subTest(path=path):
                self.assertFalse(should_ignore_change(str(root / path), root))
        self.assertFalse(should_ignore_change('/another/mobile/file.js', root))

    def test_install_is_idempotent_and_preserves_event_arguments(self):
        events = []

        class FakeWatcher:
            def _on_change(self, path, change_type, is_directory=False):
                events.append((path, change_type, is_directory))

        module = types.ModuleType('jaclang.server.watcher')
        module.JacFileWatcher = FakeWatcher
        with patch.dict(sys.modules, {'jaclang.server.watcher': module}):
            install_dev_watch_filter()
            installed = FakeWatcher._on_change
            install_dev_watch_filter()
            self.assertIs(FakeWatcher._on_change, installed)
            from dev_watch import PROJECT_ROOT
            watcher = FakeWatcher()
            watcher._on_change(str(PROJECT_ROOT / 'mobile/node_modules/foo.js'), 'modified')
            watcher._on_change(str(PROJECT_ROOT / 'frontend.jac'), 'modified', False)
            self.assertEqual(events, [(str(PROJECT_ROOT / 'frontend.jac'), 'modified', False)])


if __name__ == '__main__':
    unittest.main()
