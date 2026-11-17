# Phần 2.1: Tổng quan RDBMS & Cài đặt, Dùng thử trên Máy Cá nhân

## 1. RDBMS là gì?

**RDBMS (Relational Database Management System – Hệ quản trị Cơ sở dữ liệu Quan hệ)** là phần mềm quản lý dữ liệu theo mô hình quan hệ do Edgar F. Codd đề xuất năm 1970.

### 1.1. Các khái niệm cốt lõi
- **Database / Schema:** Không gian chứa các bảng và đối tượng liên quan.
- **Table (Relation – Bảng):** Lưu trữ một loại thực thể (ví dụ `students`, `courses`), gồm các **hàng (Row/Tuple)** đại diện cho từng bản ghi và các **cột (Column/Attribute)** có kiểu dữ liệu xác định.
- **Primary Key (Khóa chính – PK):** Cột (hoặc tập cột) xác định **duy nhất** mỗi hàng, không được `NULL` và không trùng lặp.
- **Foreign Key (Khóa ngoại – FK):** Cột trỏ tới khóa chính của bảng khác nhằm đảm bảo **toàn vẹn tham chiếu (Referential Integrity)** (không thể gán sinh viên vào một `department_id` không tồn tại).
- **Constraint (Ràng buộc):** `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, `PRIMARY KEY`, `FOREIGN KEY`.
- **Transaction & ACID:** Một nhóm câu lệnh SQL thực thi trọn vẹn hoặc hủy bỏ hoàn toàn, đảm bảo 4 tính chất:
  - **A – Atomicity (Nguyên tử):** Hoặc thành công tất cả, hoặc `ROLLBACK` hoàn toàn.
  - **C – Consistency (Nhất quán):** Dữ liệu luôn thỏa mãn mọi ràng buộc trước và sau giao dịch.
  - **I – Isolation (Cô lập):** Các giao dịch chạy đồng thời không làm sai lệch lẫn nhau.
  - **D – Durability (Bền vững):** Đã `COMMIT` thì dữ liệu được ghi xuống đĩa an toàn kể cả khi mất điện.

---

## 2. Một số RDBMS phổ biến

| RDBMS | Kiến trúc | Điểm mạnh nổi bật | Trường hợp dùng phổ biến |
| :--- | :--- | :--- | :--- |
| **PostgreSQL** | Client–Server | Tuân thủ chuẩn SQL rất cao, mạnh về `JSONB`, `ARRAY`, CTE/Window Function, MVCC, mở rộng PostGIS (dữ liệu không gian), miễn phí hoàn toàn (PostgreSQL License). | Hệ thống backend hiện đại, phân tích dữ liệu, ứng dụng doanh nghiệp. |
| **MySQL** | Client–Server | Phổ biến lâu đời, dễ triển khai, đọc nhanh với engine InnoDB hỗ trợ ACID, cộng đồng cực lớn. | Web app (LAMP/LEMP, WordPress, e-commerce, Java/Spring, Python). |
| **MariaDB** | Client–Server | Tách nhánh (fork) mã nguồn mở từ MySQL bởi chính tác giả MySQL gốc, tương thích cao với giao thức/client `mysql`, mặc định trên nhiều distro Linux (Ubuntu/Debian). | Thay thế trực tiếp cho MySQL, máy chủ Linux. |
| **SQLite** | Embedded (Serverless) | Toàn bộ DB là **1 tệp `.db` duy nhất**, không cần daemon chạy nền, tích hợp sẵn trong Python (`sqlite3`), Android, iOS, trình duyệt. | Học tập SQL, prototype, ứng dụng desktop/mobile, edge/IoT, test tự động. |

---

## 3. Cài đặt & Dùng thử trên Máy Cá nhân (Ubuntu/Linux)

Có **3 cách** tiếp cận để cài và thực hành RDBMS trên máy cá nhân:

### Cách 1: Cài trực tiếp (Native) trên Ubuntu/Linux

#### A. MariaDB / MySQL
Trên Ubuntu 26.04 LTS, gói mặc định thường là **MariaDB** (tương thích lệnh `mysql` và `mariadb`) hoặc **MySQL Server**:

```bash
# Cài MariaDB Server & Client:
sudo apt update
sudo apt install -y mariadb-server mariadb-client

# Hoặc nếu muốn cài Oracle MySQL Server:
# sudo apt install -y mysql-server

# Kiểm tra trạng thái dịch vụ:
systemctl status mariadb
```

> **Lưu ý thực tế về xác thực trên Ubuntu (`ERROR 1698`):**
> Trên Ubuntu/Debian, tài khoản `root` của MariaDB mặc định dùng plugin **`unix_socket`**, nghĩa là chỉ `sudo mariadb` (chạy dưới quyền OS `root`) mới đăng nhập được trực tiếp. Nếu user thường (ví dụ `anhh`) gõ `mariadb` sẽ gặp lỗi:
> `ERROR 1698 (28000): Access denied for user 'anhh'@'localhost'`
> **Cách khắc phục chuẩn (không mở quyền root bừa bãi):** Tạo một user riêng và cấp quyền cho database thực hành:
> ```bash
> sudo mariadb <<'SQL'
> CREATE DATABASE IF NOT EXISTS tt_thud_lab CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
> CREATE USER IF NOT EXISTS 'labuser'@'localhost' IDENTIFIED BY 'LabPass123!';
> GRANT ALL PRIVILEGES ON tt_thud_lab.* TO 'labuser'@'localhost';
> FLUSH PRIVILEGES;
> SQL
>
> # Sau đó đăng nhập bằng user thường:
> mariadb -u labuser -p tt_thud_lab
> ```

#### B. PostgreSQL
```bash
# Cài PostgreSQL & công cụ mở rộng:
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Kiểm tra dịch vụ:
systemctl status postgresql

# Đăng nhập bằng user hệ thống 'postgres' (peer authentication):
sudo -u postgres psql
```

Tạo user và database riêng trong `psql`:
```sql
CREATE USER labuser WITH PASSWORD 'LabPass123!';
CREATE DATABASE tt_thud_lab OWNER labuser;
\q
```

Kết nối qua TCP localhost:
```bash
psql -h localhost -U labuser -d tt_thud_lab
```

---

### Cách 2: Chạy PostgreSQL & MariaDB bằng Docker Compose (Khuyên dùng)

Ưu điểm khi dùng Docker (liên kết trực tiếp với Phần 1):
- Không cài thêm dịch vụ chạy nền nặng máy khi không dùng.
- Chạy song song cả **PostgreSQL 16** và **MariaDB / MySQL** cùng lúc, bật/tắt chỉ bằng 1 lệnh.
- Dữ liệu được giữ lại nhờ **Docker Volume**.

Repo này đã chuẩn bị sẵn cấu hình tại [demos/05-rdbms-and-sql/docker-compose.yml](../demos/05-rdbms-and-sql/docker-compose.yml):

```bash
cd demos/05-rdbms-and-sql
cp .env.example .env
docker compose up -d

# Dùng thử PostgreSQL CLI ngay bên trong container:
docker compose exec postgres psql -U labuser -d tt_thud_lab

# Dùng thử MariaDB CLI ngay bên trong container:
docker compose exec mariadb mariadb -u labuser -pLabPass123! tt_thud_lab

# Khi học xong, tắt gọn gàng (giữ nguyên dữ liệu volume):
docker compose down
```

---

### Cách 3: Dùng thử ngay với SQLite (Zero-Config)

Python tích hợp sẵn thư viện chuẩn `sqlite3` (trên máy thực nghiệm là SQLite 3.46.1) — không cần `sudo` hay daemon.

Repo cung cấp script [demos/05-rdbms-and-sql/run_sql_demo.py](../demos/05-rdbms-and-sql/run_sql_demo.py) tự động khởi tạo schema, nạp dữ liệu mẫu và chạy toàn bộ truy vấn mẫu, đồng thời có thể trỏ tới file `.db` hoặc PostgreSQL/MariaDB.

---

## 4. Các công cụ Giao diện (GUI Client) hỗ trợ trực quan

Bên cạnh dòng lệnh (`psql`, `mariadb`/`mysql`, `sqlite3`), khi làm việc thực tế nên dùng thêm GUI để xem ERD, bảng và kết quả truy vấn:
- **DBeaver Community:** Miễn phí, mã nguồn mở, hỗ trợ hầu hết mọi RDBMS (PostgreSQL, MySQL, MariaDB, SQLite, SQL Server, Oracle).
- **Adminer / pgAdmin 4:** Giao diện web nhẹ (Adminer chạy chỉ 1 container vài chục MB) hoặc chuyên sâu cho PostgreSQL (pgAdmin).
- **VS Code Extensions:** *Database Client (cweijan)* hoặc *SQLTools* xem bảng trực tiếp ngay trong editor.

---

## 5. Ghi nhận môi trường thực nghiệm trên máy cá nhân

Trên máy tính cá nhân chạy **Ubuntu 26.04 LTS** phục vụ báo cáo này:
- **MariaDB Server (`13.0.2-MariaDB`)**: Đã cài đặt và đang chạy qua `systemd` (`mariadb.service` – active).
- **SQLite (`3.46.1`)**: Tích hợp sẵn qua Python `3.14.4` (`sqlite3`).
- **Docker Engine (`29.6.0`)**: Sẵn sàng khởi chạy container **PostgreSQL** và **MariaDB** cô lập qua `docker compose`.

Log kiểm tra và kết quả chạy thử RDBMS + SQL được lưu tại [submissions/lab02_rdbms_sql_output.txt](../submissions/lab02_rdbms_sql_output.txt).
