# Phần 2.2: Tìm hiểu Ngôn ngữ SQL (Structured Query Language)

## 1. SQL là gì?

**SQL (Structured Query Language)** là ngôn ngữ chuẩn dùng để định nghĩa cấu trúc, thao tác và truy vấn dữ liệu trong các hệ quản trị CSDL quan hệ (RDBMS).

- **Tính chất khai báo (Declarative):** Khác với ngôn ngữ mệnh lệnh (Python/C/Java) nơi bạn viết *từng bước vòng lặp để tìm dữ liệu*, trong SQL bạn chỉ mô tả **bạn muốn lấy dữ liệu gì và thỏa mãn điều kiện nào**. Bộ tối ưu truy vấn (**Query Optimizer**) của RDBMS sẽ tự chọn chiến lược thực thi tối ưu nhất (quét bảng hay dùng Index, chọn thuật toán Hash Join hay Nested Loop Join).
- **Chuẩn ANSI/ISO & Dialects:** Đa số cú pháp cốt lõi (`SELECT`, `INSERT`, `JOIN`, `GROUP BY`, `CTE`, `WINDOW`) tuân theo chuẩn ANSI SQL, nhưng mỗi RDBMS có phần mở rộng (**dialect**) riêng (ví dụ PL/pgSQL của PostgreSQL, T-SQL của SQL Server, hàm ngày tháng của MySQL/MariaDB).

---

## 2. Năm nhóm lệnh chính của SQL

### 2.1. DDL – Data Definition Language (Định nghĩa cấu trúc)
Tác động lên cấu trúc bảng/CSDL (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`):

```sql
CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_code VARCHAR(10)  NOT NULL UNIQUE,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE students (
    student_id  INT PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(120) NOT NULL UNIQUE,
    gpa         DECIMAL(3,2) CHECK (gpa >= 0.00 AND gpa <= 4.00),
    enrolled_at DATE         NOT NULL DEFAULT CURRENT_DATE,
    dept_id     INT          NOT NULL,
    CONSTRAINT fk_students_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
```

- **Kiểu dữ liệu quan trọng:**
  - Số nguyên: `INT` (`INTEGER`), `BIGINT` (dùng cho ID lớn).
  - Số thực chính xác: `DECIMAL(p, s)` / `NUMERIC(p, s)` — **bắt buộc dùng cho tiền tệ, điểm số** thay vì `FLOAT`/`DOUBLE` để tránh sai số dấu phẩy động.
  - Chuỗi: `CHAR(n)` (độ dài cố định), `VARCHAR(n)` (độ dài thay đổi tối đa `n`), `TEXT` (văn bản dài).
  - Thời gian: `DATE`, `TIME`, `TIMESTAMP` (hoặc `DATETIME` trong MySQL).
  - Khác: `BOOLEAN`, `JSON` / `JSONB` (PostgreSQL).
- **Khác biệt cú pháp khóa tự tăng (Auto-Increment) giữa các RDBMS:**
  - **PostgreSQL (chuẩn mới):** `id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` (hoặc `SERIAL PRIMARY KEY`).
  - **MySQL / MariaDB:** `id INT AUTO_INCREMENT PRIMARY KEY`.
  - **SQLite:** `id INTEGER PRIMARY KEY AUTOINCREMENT`.
- **`DROP TABLE` vs `TRUNCATE TABLE` vs `DELETE`:**
  - `DROP TABLE`: Xóa cả dữ liệu lẫn định nghĩa bảng.
  - `TRUNCATE TABLE`: Xóa sạch toàn bộ hàng rất nhanh, giữ nguyên cấu trúc bảng (DDL).
  - `DELETE FROM ... WHERE ...`: Xóa từng hàng có điều kiện, ghi log transaction đầy đủ (DML).

---

### 2.2. DML – Data Manipulation Language (Thao tác dữ liệu)
Thêm, sửa, xóa bản ghi (`INSERT`, `UPDATE`, `DELETE`):

```sql
-- Thêm dữ liệu
INSERT INTO departments (dept_id, dept_code, dept_name)
VALUES (1, 'CNTT', 'Cong nghe thong tin'),
       (2, 'TOAN', 'Toan - Co - Tin hoc');

-- Cập nhật dữ liệu (LUÔN kiểm tra mệnh đề WHERE!)
UPDATE students
SET gpa = 3.85
WHERE student_id = 101;

-- Xóa dữ liệu có điều kiện
DELETE FROM students
WHERE student_id = 999;
```

> **Kinh nghiệm thực tế:** Trước khi chạy `UPDATE` hoặc `DELETE` trên dữ liệu thật, luôn chạy thử câu `SELECT * FROM ... WHERE ...` với đúng điều kiện `WHERE` đó, và bọc trong Transaction (`BEGIN` ... kiểm tra ... `COMMIT` hoặc `ROLLBACK`).

---

### 2.3. DQL – Data Query Language (Truy vấn dữ liệu)

Cấu trúc tổng quát của một câu `SELECT`:

```sql
SELECT DISTINCT dept_id,
       COUNT(*)          AS total_students,
       ROUND(AVG(gpa),2) AS avg_gpa
FROM students
WHERE gpa >= 2.50
GROUP BY dept_id
HAVING COUNT(*) >= 2
ORDER BY avg_gpa DESC
LIMIT 10 OFFSET 0;
```

#### Thứ tự thực thi logic của câu lệnh `SELECT` (Rất quan trọng!)
Người viết code gõ `SELECT` đầu tiên, nhưng RDBMS xử lý logic theo thứ tự sau:

```text
1. FROM / JOIN    --> Xác định và ghép các bảng nguồn
2. WHERE          --> Lọc từng HÀNG thỏa điều kiện (chưa có kết quả tổng hợp, chưa thấy alias ở SELECT!)
3. GROUP BY       --> Gom các hàng thành từng nhóm
4. HAVING         --> Lọc các NHÓM sau khi tính COUNT/SUM/AVG
5. SELECT         --> Chọn cột, tính biểu thức và đặt tên bí danh (AS alias)
6. DISTINCT       --> Loại bỏ dòng trùng lặp
7. ORDER BY       --> Sắp xếp kết quả (ở đây đã dùng được alias của SELECT)
8. LIMIT / OFFSET --> Cắt số lượng dòng trả về
```

> **Hiểu lầm kinh điển đã giải thích được nhờ thứ tự trên:**
> - Tại sao viết `SELECT gpa * 10 AS score FROM students WHERE score > 30` lại bị lỗi? Vì bước `WHERE` chạy **trước** bước `SELECT`, lúc đó bí danh `score` chưa tồn tại!
> - Khác biệt `WHERE` và `HAVING`: `WHERE` lọc **trước khi gom nhóm** (không được dùng `COUNT`, `AVG`), còn `HAVING` lọc **sau khi gom nhóm**.

#### Logic 3 giá trị của `NULL`
Trong SQL, `NULL` nghĩa là **"không xác định / thiếu giá trị"**, không phải số `0` hay chuỗi rỗng `''`.
- Mọi phép so sánh `col = NULL` hoặc `col <> NULL` đều trả về `UNKNOWN` (không đúng cũng không sai!).
- **Phải dùng:** `WHERE col IS NULL` hoặc `WHERE col IS NOT NULL`.
- Hàm xử lý `NULL`: `COALESCE(a, b, 'Mac dinh')` trả về giá trị khác `NULL` đầu tiên.

---

### 2.4. JOIN – Kết hợp nhiều bảng

Giả sử có bảng `students` (sinh viên) và `enrollments` (đăng ký học phần):

| Loại JOIN | Ý nghĩa | Giữ lại hàng không khớp? |
| :--- | :--- | :--- |
| **`INNER JOIN`** | Chỉ lấy các cặp khớp điều kiện ở **cả hai bảng** | Không |
| **`LEFT [OUTER] JOIN`** | Lấy **tất cả** hàng ở bảng trái + thông tin khớp ở bảng phải (không khớp thì cột bảng phải là `NULL`) | Có (bảng trái) |
| **`RIGHT [OUTER] JOIN`** | Ngược lại với `LEFT JOIN`: giữ tất cả bảng phải | Có (bảng phải) |
| **`FULL [OUTER] JOIN`** | Giữ tất cả hàng ở cả hai bảng *(PostgreSQL & SQLite hỗ trợ; MySQL/MariaDB dùng `LEFT JOIN UNION RIGHT JOIN`)* | Có (cả hai bảng) |
| **`CROSS JOIN`** | Tích Đề-các (mọi hàng bảng A ghép với mọi hàng bảng B) | — |

Ví dụ tìm các môn học **chưa có sinh viên nào đăng ký** (mẫu `LEFT JOIN ... WHERE ... IS NULL`):
```sql
SELECT c.course_code, c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;
```

---

### 2.5. Subquery, CTE và Window Functions

1. **Subquery (Truy vấn lồng):**
   ```sql
   SELECT full_name, gpa
   FROM students
   WHERE gpa > (SELECT AVG(gpa) FROM students);
   ```
2. **CTE – Common Table Expression (`WITH ... AS`):** Chia truy vấn phức tạp thành các bước đặt tên rõ ràng, dễ đọc và dễ bảo trì hơn subquery lồng nhiều tầng:
   ```sql
   WITH dept_stats AS (
       SELECT dept_id, AVG(gpa) AS dept_avg_gpa
       FROM students
       GROUP BY dept_id
   )
   SELECT s.full_name, s.gpa, ROUND(d.dept_avg_gpa, 2) AS dept_avg
   FROM students s
   JOIN dept_stats d ON s.dept_id = d.dept_id
   WHERE s.gpa > d.dept_avg_gpa;
   ```
3. **Window Functions (`OVER (...)`):** Tính toán trên một "cửa sổ" các hàng liên quan **mà vẫn giữ nguyên từng hàng chi tiết** (khác `GROUP BY` làm gộp mất hàng):
   ```sql
   SELECT full_name,
          dept_id,
          gpa,
          DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY gpa DESC) AS rank_in_dept
   FROM students;
   ```

---

### 2.6. TCL (Transaction Control) & DCL (Data Control)

#### TCL – Đảm bảo toàn vẹn giao dịch
```sql
BEGIN; -- (Trong MySQL/MariaDB có thể dùng START TRANSACTION)

UPDATE accounts SET balance = balance - 500000 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 500000 WHERE account_id = 2;

-- Nếu có lỗi xảy ra giữa chừng:
-- ROLLBACK;
-- Nếu cả hai bước đều hợp lệ:
COMMIT;
```

#### DCL – Phân quyền người dùng (Nguyên tắc tối thiểu quyền – Least Privilege)
```sql
-- Ví dụ trên PostgreSQL / MySQL:
GRANT SELECT, INSERT, UPDATE ON students TO app_user;
REVOKE DELETE ON students FROM app_user;
```

---

### 2.7. Index & View cơ bản

- **Index (Chỉ mục):** Thường dùng cấu trúc **B-Tree** giúp RDBMS tìm kiếm hàng theo điều kiện `WHERE`, `JOIN`, `ORDER BY` trong $O(\log N)$ thay vì quét toàn bảng (**Full Table Scan** $O(N)$). Đánh đổi: tốn thêm dung lượng lưu trữ và làm chậm nhẹ các lệnh `INSERT`/`UPDATE`/`DELETE` vì phải cập nhật Index.
  ```sql
  CREATE INDEX idx_students_dept_gpa ON students(dept_id, gpa DESC);
  ```
- **View (Bảng ảo):** Lưu trữ một câu lệnh `SELECT` đặt tên sẵn để tái sử dụng hoặc giới hạn cột người dùng được phép xem:
  ```sql
  CREATE VIEW v_student_transcript AS
  SELECT s.student_id, s.full_name, c.course_code, e.score
  FROM students s
  JOIN enrollments e ON s.student_id = e.student_id
  JOIN courses c ON e.course_id = c.course_id;
  ```

---

## 3. Thực hành bộ bài tập SQL trong Repository

Bộ kịch bản SQL hoàn chỉnh về **Hệ thống Quản lý Đào tạo Đại học** (5 bảng: `departments`, `lecturers`, `students`, `courses`, `enrollments`) nằm tại [demos/05-rdbms-and-sql/sql/](../demos/05-rdbms-and-sql/sql/):
- `01_schema.sql`: Tạo bảng, khóa chính, khóa ngoại, ràng buộc `CHECK`, `INDEX`.
- `02_seed.sql`: Nạp dữ liệu mẫu đa dạng (bao gồm trường hợp sinh viên chưa đăng ký môn, môn chưa có sinh viên đăng ký để kiểm chứng `LEFT JOIN` và `NULL`).
- `03_queries_dql_join.sql`: 10 truy vấn từ cơ bản đến nâng cao (`GROUP BY/HAVING`, `LEFT JOIN`, `CTE`, `Window Function`, `CASE WHEN`, `EXISTS`).
- `04_tcl_and_views.sql`: Thực hành `VIEW` và kiểm chứng `ROLLBACK` / `COMMIT` trong Transaction.

Chạy thử ngay bằng:
```bash
python3 demos/05-rdbms-and-sql/run_sql_demo.py
```
