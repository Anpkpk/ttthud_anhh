#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/.venv_demo"

cleanup() {
    rm -rf "${VENV_DIR}"
}
trap cleanup EXIT

echo "=== [1] Môi trường Python Hệ thống (Trước khi dùng venv) ==="
python3 "${SCRIPT_DIR}/app_env_check.py"

echo ""
echo "=== [2] Tạo & Kích hoạt Virtual Environment (.venv_demo) ==="
python3 -m venv "${VENV_DIR}"
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
python "${SCRIPT_DIR}/app_env_check.py"

echo ""
echo "=== [3] Kiểm chứng cô lập site-packages (Cài module mẫu trong venv) ==="
SITE_PKG=$(python -c "import site; print(site.getsitepackages()[0])")
cat <<'PY' > "${SITE_PKG}/demo_isolated_pkg.py"
VERSION = "1.0.0-only-inside-venv"
PY

echo -n "Import trong venv: "
python -c "import demo_isolated_pkg; print(demo_isolated_pkg.VERSION)"

deactivate

echo -n "Import ngoài hệ thống: "
if python3 -c "import demo_isolated_pkg" 2>/dev/null; then
    echo "FOUND (unexpected)"
else
    echo "ModuleNotFoundError (Hệ thống sạch sẽ, không bị ảnh hưởng!)"
fi
