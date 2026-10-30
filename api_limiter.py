"""Process-local rate limiter for shared OpenRouter usage."""

from collections import deque
from datetime import datetime, timezone
from threading import Lock
from time import monotonic

MAX_PER_MINUTE = 10
MAX_PER_DAY = 40

_lock = Lock()
_recent_requests = deque()
_daily_count = 0
_current_day = None


def allow_request() -> bool:
    global _daily_count, _current_day

    with _lock:
        now = monotonic()
        today = datetime.now(timezone.utc).date()

        if today != _current_day:
            _current_day = today
            _daily_count = 0

        while _recent_requests and now - _recent_requests[0] >= 60:
            _recent_requests.popleft()

        if (
            len(_recent_requests) >= MAX_PER_MINUTE
            or _daily_count >= MAX_PER_DAY
        ):
            return False

        _recent_requests.append(now)
        _daily_count += 1
        return True
