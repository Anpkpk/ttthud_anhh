# Báo cáo Thực hành: Môi trường Ảo hóa, Python Managers, Git/GitHub & RDBMS/SQL

Repository tổng hợp báo cáo lý thuyết, mã nguồn demo có thể tái lập và minh chứng kết quả thực hành trên máy cá nhân (**Ubuntu 26.04 LTS**).

- **Tác giả:** `Anpkpk` (`23001573@hus.edu.vn`)
- **Nhánh mặc định:** `main`

---

## Mục lục Nội dung Báo cáo

### Phần 1: Ảo hóa, Quản lý Môi trường Python & Git/GitHub
1. **[Ảo hóa & Cô lập: Virtual Environment vs Virtual Machine vs Docker Container](docs/01-virtualization-and-containers.md)**
   - Cơ chế hoạt động của Python `venv`, Hypervisor Type 1/2 (KVM/QEMU), Docker Container (Linux Namespaces, `cgroups`, UnionFS `overlay2`).
   - Sơ đồ kiến trúc & bảng so sánh chi tiết 10 tiêu chí.
2. **[Các Python Environment Manager: `venv`, `virtualenv`, `pyenv`, `conda`, `uv`](docs/02-python-environment-managers.md)**
   - Phân biệt vai trò từng công cụ, cơ chế shims của `pyenv`, quản lý binary đa ngôn ngữ của `conda`, kiến trúc Rust của `uv`.
   - Bảng so sánh & khuyến nghị lựa chọn thực tế.
3. **[Git, GitHub & Quy trình Submit Bài tập](docs/03-git-and-github-workflow.md)**
   - 4 vùng trạng thái Git, quy trình nhánh/merge/conflict, xác thực SSH/HTTPS, Conventional Commits và hướng dẫn từng bước đẩy repo lên GitHub.

### Phần 2: Hệ quản trị CSDL Quan hệ (RDBMS) & Ngôn ngữ SQL
4. **[Tổng quan RDBMS, Cài đặt & Dùng thử trên Máy Cá nhân](docs/04-rdbms-installation-and-setup.md)**
   - Mô hình quan hệ, khóa chính/ngoại, ACID.
   - So sánh MySQL, MariaDB, PostgreSQL, SQLite.
   - Hướng dẫn cài Native trên Ubuntu (kèm xử lý lỗi `unix_socket` MariaDB), triển khai qua Docker Compose và dùng thử SQLite zero-config.
5. **[Tìm hiểu Ngôn ngữ SQL (Structured Query Language)](docs/05-sql-language-fundamentals.md)**
   - Ngôn ngữ khai báo, thứ tự thực thi logic câu `SELECT`, logic 3 giá trị của `NULL`.
   - Đầy đủ 5 nhóm lệnh: **DDL**, **DML**, **DQL** (`GROUP BY`/`HAVING`, `JOIN`, Subquery, `CTE`, `Window Functions`), **TCL** (Transaction), **DCL** (Phân quyền), kèm **Index** và **View**.

---

## Cấu trúc Thư mục & Demo Thực hành

```text
.
├── docs/                                   # Tài liệu báo cáo lý thuyết chi tiết (5 chương)
├── demos/
│   ├── 01-venv-vs-isolation/               # Demo tạo venv, kiểm tra sys.prefix & cô lập site-packages
│   ├── 02-virtual-machine-qemu/            # Demo kiểm tra KVM/VT-x & tạo ổ đĩa ảo qcow2 + snapshot
│   ├── 03-docker-container/                # Dockerfile, app.py & docker-compose minh họa Namespaces/cgroups
│   ├── 04-python-env-managers/             # Mẫu cấu hình requirements.txt, environment.yml, pyproject.toml, .python-version
│   └── 05-rdbms-and-sql/                   # Docker Compose (Postgres + MariaDB + Adminer), bộ 4 file SQL & script chạy thử
└── submissions/
    ├── SUBMISSION_CHECKLIST.md             # Checklist & hướng dẫn push submission lên GitHub
    ├── lab01_env_vm_docker_output.txt      # Log kết quả chạy thực tế Phần 1
    └── lab02_rdbms_sql_output.txt          # Log kết quả chạy thực tế Phần 2
```

---

## Hướng dẫn Chạy nhanh Các Demo

### 1. Chạy Demo Phần 1
```bash
bash demos/01-venv-vs-isolation/demo_venv.sh
bash demos/02-virtual-machine-qemu/demo_vm_check.sh
bash demos/03-docker-container/run_demo.sh
bash demos/04-python-env-managers/compare_managers.sh
```

### 2. Chạy Demo Phần 2 (RDBMS & SQL)
**Cách nhanh nhất (dùng SQLite tích hợp sẵn trong Python, không cần cài thêm dịch vụ):**
```bash
python3 demos/05-rdbms-and-sql/run_sql_demo.py
```

**Chạy với PostgreSQL 16 & MariaDB 11 qua Docker Compose:**
```bash
cd demos/05-rdbms-and-sql
cp .env.example .env
docker compose up -d
```
*(Ghi chú: MariaDB trong Docker được map ra cổng `3307` trên Host để không xung đột với dịch vụ MariaDB native cổng `3306` nếu đã cài trên máy.)*

---

## Nộp bài (Submission)
Xem hướng dẫn đầy đủ tại [submissions/SUBMISSION_CHECKLIST.md](submissions/SUBMISSION_CHECKLIST.md).
