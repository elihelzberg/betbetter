"""Run the one shared Jac backend and desktop dev server on stable ports."""
import os
import re
import shutil
import socket
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def find_jac():
    """Prefer a compatible native compiler over an older pip-installed CLI."""
    override = os.environ.get('JAC_BIN')
    candidates = [override] if override else [shutil.which('jac'), str(Path.home() / '.local/bin/jac')]
    for candidate in dict.fromkeys(path for path in candidates if path):
        try:
            result = subprocess.run([candidate, '--version'], capture_output=True, text=True, timeout=30)
            match = re.search(r'\b(\d+)\.(\d+)\.(\d+)\b', result.stdout)
            if result.returncode == 0 and match:
                version = tuple(map(int, match.groups()))
                if (0, 37, 23) <= version < (0, 38, 0):
                    return candidate
        except (OSError, subprocess.TimeoutExpired):
            continue
    raise RuntimeError('Jac 0.37.23+ (0.37.x) is required. Install the native compiler from '
                       'https://jaclang.org/docs/latest/quick-guide/install or set JAC_BIN to its path.')


def main():
    # Fail before Jac rewrites the shared Vite config if another instance owns it.
    for port in (8000, 8001):
        with socket.socket() as probe:
            # A stopped dev server can leave TIME_WAIT sockets; only a live
            # listener should prevent a restart on the same stable ports.
            probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            try:
                probe.bind(('0.0.0.0', port))
            except OSError:
                print(f'Port {port} is already in use. Keep only one betBetter Jac server running. '
                      'Expo runs separately on port 8081.', file=sys.stderr)
                return 1
    try:
        compiler = find_jac()
        print(f'Using {compiler}', flush=True)
        return subprocess.call([compiler, 'run', '--dev', '--port', '8000', '--api-port', '8001',
                                '--host', '0.0.0.0'], cwd=ROOT)
    except RuntimeError as error:
        print(str(error), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == '__main__':
    sys.exit(main())
