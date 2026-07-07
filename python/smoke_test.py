#!/usr/bin/env python3
"""Post-deploy smoke test.

Checks that each given endpoint responds, so a pipeline can fail fast when a
deploy leaves something unreachable. Standard library only, no dependencies.

Example:
    python3 smoke_test.py https://dxxxx.cloudfront.net http://my-alb-123.elb.amazonaws.com
"""
from __future__ import annotations

import argparse
import sys
import time
import urllib.error
import urllib.request


def check(url: str, timeout: float, retries: int, delay: float) -> tuple[bool, str]:
    """Probe one URL, retrying while it warms up. Returns (ok, detail)."""
    last = ""
    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "smoke-test"})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                status = resp.status
            if status < 400:
                return True, f"HTTP {status}"
            last = f"HTTP {status}"
        except urllib.error.HTTPError as exc:
            last = f"HTTP {exc.code}"
        except urllib.error.URLError as exc:
            last = f"unreachable: {exc.reason}"
        except TimeoutError:
            last = "timeout"

        if attempt < retries:
            time.sleep(delay)
    return False, last


def main() -> int:
    parser = argparse.ArgumentParser(description="Smoke-test deployed endpoints.")
    parser.add_argument("urls", nargs="+", help="URLs to check.")
    parser.add_argument("--timeout", type=float, default=10.0, help="Per-request timeout (s).")
    parser.add_argument("--retries", type=int, default=5, help="Attempts per URL.")
    parser.add_argument("--delay", type=float, default=5.0, help="Seconds between retries.")
    args = parser.parse_args()

    failures = 0
    for url in args.urls:
        ok, detail = check(url, args.timeout, args.retries, args.delay)
        print(f"[{'PASS' if ok else 'FAIL'}] {url} -> {detail}")
        if not ok:
            failures += 1

    healthy = len(args.urls) - failures
    print(f"\n{healthy}/{len(args.urls)} healthy")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
