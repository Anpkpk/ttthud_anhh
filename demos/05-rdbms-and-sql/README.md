# Demo 5: Cài đặt / Dùng thử RDBMS & Thực hành Ngôn ngữ SQL

## 1. Dùng thử nhanh với SQLite (Zero-Config)
Chạy script Python sử dụng mô-đun `sqlite3` tích hợp sẵn để tạo lược đồ 5 bảng (`01_schema.sql`), nạp dữ liệu mẫu (`02_seed.sql`), kiểm chứng khóa ngoại/ràng buộc `CHECK`, chạy 10 truy vấn DQL (`03_queries_dql_join.sql`), tạo `VIEW` (`04_tcl_and_views.sql`) và kiểm chứng Transaction `ROLLBACK`/`COMMIT`:

```bash
python3 demos/05-rdbms-and-sql/run_sql_demo.py
```

Muốn lưu ra tệp `.db` để mở bằng DBeaver/VS Code:
```bash
python3 demos/05-rdbms-and-sql/run_sql_demo.py --db-file demos/05-rdbms-and-sql/lab_demo.db
```

---

## 2. Dùng thử PostgreSQL 16 & MariaDB 11 qua Docker Compose

```bash
cd demos/05-rdbms-and-sql
cp .env.example .env
docker compose up -d
```

Sau khi container khỏe (`docker compose ps`), nạp trực tiếp các tệp `.sql` vào PostgreSQL hoặc MariaDB:

### Trên PostgreSQL 16 (`localhost:5432`)
```bash
docker compose exec postgres psql -U labuser -d tt_thud_lab -f /sql/01_schema.sql
docker compose exec postgres psql -U labuser -d tt_thud_lab -f /sql/02_seed.sql
docker compose exec postgres psql -U labuser -d tt_thud_lab -f /sql/03_queries_dql_join.sql
```

### Trên MariaDB 11 (`localhost:3307` – tránh trùng cổng 3306 của host)
```bash
docker compose exec -T mariadb mariadb -u labuser -pLabPass123_ChangeMe tt_thud_lab < sql/01_schema.sql
docker compose exec -T mariadb mariadb -u labuser -pLabPass123_ChangeMe tt_thud_lab < sql/02_seed.sql
docker compose exec -T mariadb mariadb -u labuser -pLabPass123_ChangeMe tt_thud_lab < sql/03_queries_dql_join.sql
```

### Giao diện web Adminer
Truy cập trình duyệt: `http://localhost:8081` (chọn System: `PostgreSQL` với Server `postgres` hoặc `MySQL` với Server `mariadb`).

### Tắt container khi hoàn tất
```bash
docker compose down
```
