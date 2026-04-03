from collections import defaultdict, deque
from dataclasses import dataclass
from threading import Lock
import time


@dataclass(frozen=True)
class RateLimitResult:
    allowed: bool
    retry_after_seconds: int | None = None


class InMemoryRateLimiter:
    def __init__(
        self,
        *,
        max_requests: int,
        window_seconds: int,
    ) -> None:
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._events: dict[str, deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def check(self, key: str) -> RateLimitResult:
        now = time.time()
        cutoff = now - self.window_seconds
        with self._lock:
            events = self._events[key]
            while events and events[0] < cutoff:
                events.popleft()

            if len(events) >= self.max_requests:
                retry_after = max(1, int(self.window_seconds - (now - events[0])))
                return RateLimitResult(allowed=False, retry_after_seconds=retry_after)

            events.append(now)
            return RateLimitResult(allowed=True)
