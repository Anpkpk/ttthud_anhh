#!/usr/bin/env bash
set -euo pipefail

echo "=== Kiểm tra các Python Environment Manager trên máy cá nhân ==="

echo -n "1. python3 (stdlib venv): "
python3 --version

echo -n "2. pip: "
python3 -m pip --version 2>/dev/null || echo "chưa cài pip"

echo -n "3. virtualenv: "
if command -v virtualenv >/dev/null 2>&1; then
    virtualenv --version
else
    echo "chưa cài (cài thử: pip install virtualenv hoặc uv tool install virtualenv)"
fi

echo -n "4. pyenv: "
if command -v pyenv >/dev/null 2>&1; then
    pyenv --version
else
    echo "chưa cài (cài thử: curl -fsSL https://pyenv.run | bash)"
fi

echo -n "5. conda: "
CONDA_BIN=""
if command -v conda >/dev/null 2>&1; then
    CONDA_BIN="$(command -v conda)"
elif [ -x "${HOME}/miniconda3/bin/conda" ]; then
    CONDA_BIN="${HOME}/miniconda3/bin/conda"
fi

if [ -n "${CONDA_BIN}" ]; then
    "${CONDA_BIN}" --version
    echo "--- Danh sách môi trường Conda hiện có trên máy: ---"
    "${CONDA_BIN}" env list
else
    echo "chưa cài Miniconda/Anaconda"
fi

echo -n "6. uv: "
if command -v uv >/dev/null 2>&1; then
    uv --version
else
    echo "chưa cài (cài thử: curl -LsSf https://astral.sh/uv/install.sh | sh)"
fi
