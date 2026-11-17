#!/usr/bin/env python3
"""Ứng dụng mẫu minh họa sự cô lập của Docker Container (Namespaces & Shared Kernel)."""

import argparse
import json
import os
import platform
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path


def read_os_name() -> str:
    os_release = Path("/etc/os-release")
    if os_release.exists():
        for line in os_release.read_text(encoding="utf-8").splitlines():
            if line.startswith("PRETTY_NAME="):
                return line.split("=", 1)[1].strip().strip('"')
    return platform.system()


def collect_info() -> dict:
    return {
        "app_env": os.environ.get("APP_ENV", "local"),
        "hostname_uts_namespace": platform.node(),
        "pid_inside_namespace": os.getpid(),
        "userland_os": read_os_name(),
        "shared_host_kernel": os.uname().release,
        "python_version": platform.python_version(),
        "python_executable": sys.executable,
    }


class InfoHandler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        payload = json.dumps(collect_info(), indent=2, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args) -> None:
        print(f"[HTTP] {self.address_string()} - {format % args}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--serve", action="store_true", help="Chạy HTTP server trên cổng 8080")
    args = parser.parse_args()

    if args.serve:
        server = HTTPServer(("0.0.0.0", 8080), InfoHandler)
        print("Container HTTP server listening on http://0.0.0.0:8080 ...")
        server.serve_forever()
    else:
        print(json.dumps(collect_info(), indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
