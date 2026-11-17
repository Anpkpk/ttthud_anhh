#!/usr/bin/env python3
import platform
import sys


def main() -> None:
    print(f"uv demo running with Python {platform.python_version()} ({sys.executable})")


if __name__ == "__main__":
    main()
