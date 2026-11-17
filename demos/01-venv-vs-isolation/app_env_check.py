#!/usr/bin/env python3
"""Kiểm tra mức độ cô lập của môi trường Python hiện tại (Host vs venv vs Container)."""

import os
import platform
import site
import sys


def main() -> None:
    in_venv = sys.prefix != sys.base_prefix
    print(f"Python version : {platform.python_version()}")
    print(f"Executable     : {sys.executable}")
    print(f"sys.prefix     : {sys.prefix}")
    print(f"sys.base_prefix: {sys.base_prefix}")
    print(f"In virtual env?: {in_venv}")
    print(f"VIRTUAL_ENV    : {os.environ.get('VIRTUAL_ENV', '<not set>')}")
    print(f"Site packages  : {site.getsitepackages()}")
    print(f"Hostname       : {platform.node()}")
    print(f"OS / Kernel    : {platform.system()} {os.uname().release}")
    print(f"Process PID    : {os.getpid()}")


if __name__ == "__main__":
    main()
