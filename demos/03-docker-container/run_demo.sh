#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="tt-thud/isolation-demo:latest"

echo "=== [1] Thông tin trên máy Host (Ubuntu) ==="
echo "Host OS      : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Host Kernel  : $(uname -r)"
echo "Host Hostname: $(hostname)"

echo ""
echo "=== [2] Build Docker Image (Alpine + Python 3) ==="
docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"

echo ""
echo "=== [3] Chạy Container (Cô lập Userland, PID=1, Hostname riêng, nhưng dùng chung Kernel) ==="
docker run --rm --name tt_thud_once \
    --memory=128m --cpus=0.5 \
    "${IMAGE_NAME}" python3 app.py

echo ""
echo "=== [4] Kiểm tra danh sách tiến trình bên trong Container (PID Namespace) ==="
docker run --rm "${IMAGE_NAME}" ps aux
