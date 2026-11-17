# Phần 1.4: Các Python Environment Manager (`venv`, `virtualenv`, `pyenv`, `conda`, `uv`)

## 1. Phân biệt các nhóm công cụ trong hệ sinh thái Python

Người mới học Python thường nhầm lẫn các công cụ vì chúng có tên gần giống nhau. Thực tế có 4 vai trò riêng biệt:

1. **Package Installer (Trình cài gói):** `pip`, `uv pip` — tải và cài thư viện từ PyPI.
2. **Virtual Environment Manager (Quản lý môi trường ảo):** `venv`, `virtualenv` — tách thư mục `site-packages` cho từng dự án trên một phiên bản Python có sẵn.
3. **Python Version Manager (Quản lý phiên bản trình thông dịch):** `pyenv`, `uv python` — cài đặt và chuyển đổi giữa nhiều phiên bản Python (3.10, 3.11, 3.12, 3.14...) trên cùng một máy.
4. **All-in-One / Environment + Dependency Resolver:** `conda` (quản lý cả binary phi-Python) và `uv` (thay thế đồng thời `pyenv` + `venv` + `pip` + `pip-tools` + `poetry`).

---

## 2. Chi tiết từng công cụ

### 2.1. `venv` (Tích hợp sẵn trong Python)
- **Nguồn gốc:** Có sẵn trong thư viện chuẩn từ Python 3.3 (`python3 -m venv`). Không cần cài thêm công cụ bên ngoài (trên Ubuntu/Debian chỉ cần gói `python3-venv` nếu bản minimal chưa có `ensurepip`).
- **Cách hoạt động:** Tạo thư mục chứa symlink tới binary Python hiện tại và thư mục `site-packages` độc lập.
- **Lệnh cơ bản:**
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate        # Linux/macOS
  # .venv\Scripts\Activate.ps1     # Windows PowerShell
  python -m pip install -r requirements.txt
  deactivate
  ```
- **Ưu điểm:** Chuẩn chính thức, nhẹ, luôn có sẵn, không cần cài đặt thêm.
- **Nhược điểm:** Không tự tải phiên bản Python khác; `pip` giải quyết phụ thuộc chậm hơn `uv`; `requirements.txt` mặc định không có hash lock đầy đủ nếu không dùng `pip-compile`.

### 2.2. `virtualenv`
- **Nguồn gốc:** Dự án mã nguồn mở ra đời trước `venv` (hỗ trợ cả Python 2 và Python 3), hiện được bảo trì bởi PyPA.
- **Khác biệt so với `venv`:**
  - Nhanh hơn `venv` đáng kể nhờ cơ chế cache seed (`pip`, `setuptools`, `wheel`) qua `app-data`.
  - Hỗ trợ tạo môi trường trỏ tới phiên bản Python khác qua cờ `-p` / `--python` (ví dụ `virtualenv -p python3.11 .venv311`).
  - Hỗ trợ nâng cấp/tùy biến seed packages linh hoạt hơn.
- **Lệnh cơ bản:**
  ```bash
  pip install virtualenv
  virtualenv .venv
  virtualenv -p /usr/bin/python3.12 .venv312
  ```

### 2.3. `pyenv` (+ `pyenv-virtualenv`)
- **Vai trò cốt lõi:** Quản lý **nhiều phiên bản Python interpreter** song song trên cùng máy (ví dụ vừa cần Python 3.10 cho dự án cũ, vừa cần Python 3.14 cho dự án mới) mà không làm rối Python của hệ điều hành.
- **Cơ chế hoạt động (Shims):**
  - `pyenv` chèn thư mục `~/.pyenv/shims` lên **đầu** biến `PATH`.
  - Khi bạn gõ `python` hoặc `pip`, shell chạy tệp shim của `pyenv`, sau đó `pyenv` kiểm tra theo thứ tự ưu tiên:
    1. Biến môi trường `PYENV_VERSION`
    2. Tệp `.python-version` trong thư mục hiện tại (hoặc thư mục cha)
    3. Cấu hình toàn cục `~/.pyenv/version`
  - Và chuyển hướng sang đúng bản Python trong `~/.pyenv/versions/<version>/bin/`.
- **Lệnh cơ bản:**
  ```bash
  pyenv install 3.12.7              # Tải source và biên dịch Python 3.12.7
  pyenv global 3.12.7               # Đặt mặc định toàn máy
  pyenv local 3.11.9                # Tạo file .python-version cho thư mục dự án
  pyenv virtualenv 3.12.7 my-proj   # (Với plugin pyenv-virtualenv)
  ```
- **Lưu ý:** Trên Linux, `pyenv install` biên dịch Python từ mã nguồn C nên cần cài sẵn các thư viện build (`build-essential`, `libssl-dev`, `zlib1g-dev`, `libbz2-dev`, `libreadline-dev`, `libsqlite3-dev`, `libffi-dev`).

### 2.4. `conda` (Anaconda / Miniconda / Miniforge / Mamba)
- **Vai trò cốt lõi:** Trình quản lý gói và môi trường **đa ngôn ngữ** (language-agnostic), quản lý cả gói Python lẫn **thư viện hệ thống biên dịch sẵn** (C/C++, CUDA, cuDNN, MKL, OpenCV, FFmpeg, GDAL, R...).
- **Phân biệt các bản phân phối:**
  - **Anaconda:** Đóng gói sẵn hàng trăm thư viện Data Science (~vài GB).
  - **Miniconda:** Bản tối giản chỉ gồm `conda` + Python (~vài trăm MB) — gọn và phổ biến hơn (hiện đã cài trên máy thực nghiệm).
  - **Miniforge / Mamba:** Dùng kênh cộng đồng `conda-forge` mặc định và solver C++ `libmamba` siêu nhanh.
- **Lệnh cơ bản:**
  ```bash
  conda create -n ds_env python=3.12 numpy pandas -y
  conda activate ds_env
  conda env export --from-history > environment.yml
  conda env create -f environment.yml
  conda deactivate
  ```
- **Ưu điểm:** Tuyệt vời cho AI/Machine Learning/Khoa học dữ liệu khi cần CUDA/C++ binaries đồng bộ mà `pip` khó biên dịch trên máy người dùng.
- **Nhược điểm:** Môi trường khá nặng; solver cũ khá chậm (bản mới dùng `libmamba` đã cải thiện mạnh); cần cẩn trọng khi trộn `conda install` và `pip install` (nên cài gói conda trước, `pip` sau).

### 2.5. `uv` (Astral)
- **Nguồn gốc:** Phát triển bởi **Astral** (nhóm tạo ra linter `ruff`), viết hoàn toàn bằng ngôn ngữ **Rust**.
- **Tại sao `uv` đang trở thành chuẩn mực mới trong Python?**
  - **Tốc độ vượt trội (10x – 100x nhanh hơn `pip`):** Nhờ song song hóa tải về, bộ nhớ đệm toàn cục (global cache dùng hardlink/CoW tránh nhân bản file), và bộ giải phụ thuộc PubGrub viết bằng Rust.
  - **Hợp nhất công cụ (All-in-one):** Một binary duy nhất thay thế `pyenv` + `venv` + `pip` + `pip-tools` + `pipx` + `poetry`.
  - **Quản lý chuẩn hiện đại:** Dùng `pyproject.toml` (PEP 621) và sinh tệp khóa `uv.lock` đa nền tảng giúp tái lập chính xác môi trường giữa Linux / macOS / Windows.
- **Lệnh cơ bản:**
  ```bash
  uv python install 3.12            # Tải sẵn binary Python (không cần tự biên dịch như pyenv)
  uv init my_project                # Tạo pyproject.toml, .python-version, main.py
  uv add fastapi sqlalchemy         # Cài gói + cập nhật pyproject.toml & uv.lock
  uv sync                           # Đồng bộ chính xác môi trường từ uv.lock
  uv run python main.py             # Tự kích hoạt .venv và chạy lệnh
  uv tool install ruff              # Cài CLI tool tách biệt (thay thế pipx)
  ```

---

## 3. Bảng so sánh tổng hợp

| Tiêu chí | `venv` | `virtualenv` | `pyenv` (+ plugin) | `conda` / `mamba` | `uv` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Ngôn ngữ / Nền tảng** | Python (stdlib) | Python (PyPA) | Shell scripts (sh) | Python + C++ (`libmamba`) | Rust (1 binary độc lập) |
| **Quản lý phiên bản Python?** | Không | Không (chỉ trỏ tới Python đã cài) | **Có** (biên dịch từ source) | **Có** (tải binary) | **Có** (tải binary cực nhanh) |
| **Quản lý non-Python (CUDA, C libs)?** | Không | Không | Không | **Có** (thế mạnh lớn nhất) | Không (chỉ wheel/sdist Python) |
| **Lockfile tái lập chuẩn xác?** | Không mặc định | Không mặc định | Không | Có (`conda-lock` / `explicit`) | **Có** (`uv.lock` đa nền tảng) |
| **Tốc độ tạo env & giải gói** | Chậm – Trung bình | Khá nhanh | Chậm khi build Python | Trung bình (`libmamba` nhanh) | **Cực nhanh** (10–100x `pip`) |
| **Dùng trong Docker?** | Ít (container đã cô lập sẵn) | Ít | Không khuyến nghị | Đôi khi (cho GPU/AI) | **Rất tốt** (build image siêu nhanh) |
| **Phù hợp nhất cho** | Bài tập đơn giản, môi trường tối giản | Cần hỗ trợ nhiều Python cũ nhanh | Dev cần switch nhiều Python global/local | AI/ML, Khoa học dữ liệu, thư viện C/CUDA | Mọi dự án Python hiện đại (Web, CLI, Data, CI/CD) |

---

## 4. Khuyến nghị lựa chọn thực tế

1. **Dự án Python thuần / Backend / Script / Microservice:** Chọn **`uv`** (nếu không được cài thêm công cụ ngoài thì dùng **`venv`**).
2. **Dự án AI/ML, Khoa học dữ liệu cần CUDA, PyTorch, GDAL, C++ bindings phức tạp:** Dùng **`conda` (Miniconda/Miniforge)** hoặc kết hợp **`uv`**.
3. **Cần duy trì nhiều bản Python song song theo từng thư mục dự án cũ:** Dùng **`pyenv`** hoặc **`uv python pin`**.

Xem thư mục thực hành tại [demos/04-python-env-managers/](../demos/04-python-env-managers/) để xem các tệp cấu hình mẫu (`requirements.txt`, `environment.yml`, `pyproject.toml`, `.python-version`) và chạy script đối chiếu.
