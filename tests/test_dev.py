"""The shared launcher must pick the native runtime and keep both ports fixed."""
import subprocess
import unittest
from unittest.mock import patch

from dev import find_jac


class LauncherTests(unittest.TestCase):
    @patch.dict('os.environ', {}, clear=True)
    @patch('dev.shutil.which', return_value='/old/jac')
    @patch('dev.subprocess.run')
    def test_skips_legacy_cli_and_uses_compatible_native_runtime(self, run, _which):
        run.side_effect = [
            subprocess.CompletedProcess([], 0, 'Version: 0.16.7'),
            subprocess.CompletedProcess([], 0, 'jac 0.37.25 (Darwin arm64)'),
        ]
        self.assertTrue(find_jac().endswith('/.local/bin/jac'))

    @patch.dict('os.environ', {'JAC_BIN': '/custom/jac'}, clear=True)
    @patch('dev.subprocess.run')
    def test_honors_explicit_compatible_compiler(self, run):
        run.return_value = subprocess.CompletedProcess([], 0, 'jac 0.37.23')
        self.assertEqual(find_jac(), '/custom/jac')
        run.assert_called_once()

    @patch.dict('os.environ', {'JAC_BIN': '/custom/jac'}, clear=True)
    @patch('dev.subprocess.run')
    def test_rejects_incompatible_override_with_actionable_error(self, run):
        run.return_value = subprocess.CompletedProcess([], 0, 'jac 0.16.7')
        with self.assertRaisesRegex(RuntimeError, 'Install the native compiler'):
            find_jac()


if __name__ == '__main__':
    unittest.main()
