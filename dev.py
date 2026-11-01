"""Run the one shared Jac backend and desktop dev server on stable ports."""
import socket
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def main():
    # Fail before Jac rewrites the shared Vite config if another instance owns it.
    for port in (8000, 8001):
        with socket.socket() as probe:
            try:
                probe.bind(('0.0.0.0', port))
            except OSError:
                print(f'Port {port} is already in use. Keep only one betBetter Jac server running. '
                      'Expo runs separately on port 8081.', file=sys.stderr)
                return 1
    try:
        return subprocess.call(['jac', 'run', '--dev', '--port', '8000', '--api-port', '8001',
                                '--host', '0.0.0.0'], cwd=ROOT)
    except KeyboardInterrupt:
        return 130


if __name__ == '__main__':
    sys.exit(main())
