# Checklist & Hướng dẫn Nộp Bài (Submission)

## 1. Danh mục hoàn thành theo yêu cầu đề bài

### Phần 1: Ảo hóa, Môi trường Python & Git/GitHub
- [x] **Lý thuyết & So sánh Virtual Environment vs Virtual Machine vs Docker Container:** [docs/01-virtualization-and-containers.md](../docs/01-virtualization-and-containers.md)
- [x] **Demo Virtual Environment (`venv`):** [demos/01-venv-vs-isolation/](../demos/01-venv-vs-isolation/)
- [x] **Demo Virtual Machine (QEMU/KVM + `qcow2`):** [demos/02-virtual-machine-qemu/](../demos/02-virtual-machine-qemu/)
- [x] **Demo Docker Container (`Dockerfile`, `docker-compose.yml`, Namespaces & `cgroups`):** [demos/03-docker-container/](../demos/03-docker-container/)
- [x] **Tìm hiểu các Python Environment Manager (`uv`, `pyenv`, `conda`, `virtualenv`, `venv`):** [docs/02-python-environment-managers.md](../docs/02-python-environment-managers.md) & [demos/04-python-env-managers/](../demos/04-python-env-managers/)
- [x] **Làm quen Git, GitHub & quy trình Submit:** [docs/03-git-and-github-workflow.md](../docs/03-git-and-github-workflow.md)
- [x] **Minh chứng kết quả chạy thực tế Phần 1:** [submissions/lab01_env_vm_docker_output.txt](./lab01_env_vm_docker_output.txt)

### Phần 2: RDBMS & Ngôn ngữ SQL
- [x] **Tổng quan RDBMS & Hướng dẫn cài đặt, dùng thử (MariaDB/MySQL, PostgreSQL, SQLite):** [docs/04-rdbms-installation-and-setup.md](../docs/04-rdbms-installation-and-setup.md)
- [x] **Tìm hiểu ngôn ngữ SQL (DDL, DML, DQL, JOIN, Subquery, CTE, Window Functions, TCL, DCL, Index/View):** [docs/05-sql-language-fundamentals.md](../docs/05-sql-language-fundamentals.md)
- [x] **Kịch bản Docker Compose (PostgreSQL 16 + MariaDB 11 + Adminer) & SQL mẫu:** [demos/05-rdbms-and-sql/](../demos/05-rdbms-and-sql/)
- [x] **Minh chứng kết quả chạy thực tế Phần 2:** [submissions/lab02_rdbms_sql_output.txt](./lab02_rdbms_sql_output.txt)

---

## 2. Kiểm tra lại toàn bộ Demo trước khi Push

```bash
# Chạy lại demo Phần 1
bash demos/01-venv-vs-isolation/demo_venv.sh
bash demos/02-virtual-machine-qemu/demo_vm_check.sh
bash demos/03-docker-container/run_demo.sh
bash demos/04-python-env-managers/compare_managers.sh

# Chạy lại demo Phần 2 (SQLite zero-config)
python3 demos/05-rdbms-and-sql/run_sql_demo.py
```

*(Tùy chọn chạy PostgreSQL & MariaDB qua Docker Compose)*:
```bash
cd demos/05-rdbms-and-sql
cp .env.example .env
docker compose up -d
```

---

## 3. Các bước Submit Repository lên GitHub

1. Kiểm tra trạng thái Git tại thư mục gốc repo:
   ```bash
   git status
   git log --oneline --graph
   ```
2. Tạo một Repository trống mới trên GitHub (không tích `Add a README`, `.gitignore`, hay `license` để tránh conflict).
3. Gắn remote `origin` và đẩy code lên nhánh `main` (thay `<github-username>` và `<repo-name>`):
   ```bash
   git remote add origin git@github.com:<github-username>/<repo-name>.git
   git push -u origin main
   ```
4. *(Tùy chọn)* Gắn tag phiên bản nộp bài:
   ```bash
   git tag -a v1.0-submission -m "Nop bao cao Phan 1 va Phan 2"
   git push origin v1.0-submission
   ```
5. Mở link repo trên trình duyệt ở chế độ ẩn danh (nếu repo public) hoặc kiểm tra hiển thị các file Markdown, sơ đồ Mermaid và thư mục `submissions/` trước khi nộp link cho giảng viên.
