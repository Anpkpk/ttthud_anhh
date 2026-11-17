-- =============================================================================
-- 02_seed.sql - DML: Nạp dữ liệu mẫu phục vụ thực hành truy vấn SQL
-- =============================================================================

INSERT INTO departments (dept_id, dept_code, dept_name) VALUES
    (1, 'CNTT', 'Cong nghe thong tin'),
    (2, 'TOAN', 'Toan - Co - Tin hoc'),
    (3, 'KHDL', 'Khoa hoc du lieu');

INSERT INTO lecturers (lecturer_id, full_name, email, dept_id) VALUES
    (1, 'TS. Nguyen Minh Tuan',  'tuan.nm@university.edu.vn', 1),
    (2, 'ThS. Tran Thu Ha',      'ha.tt@university.edu.vn',   1),
    (3, 'PGS. Le Hoang Nam',     'nam.lh@university.edu.vn',  2),
    (4, 'TS. Pham Quoc Bao',     'bao.pq@university.edu.vn',  3);

INSERT INTO students (student_id, student_code, full_name, email, cohort_year, gpa, dept_id) VALUES
    (101, '23001573', 'Nguyen Van An',    'an.nv@sv.edu.vn',    2023, 3.65, 1),
    (102, '23001574', 'Tran Thi Binh',    'binh.tt@sv.edu.vn',  2023, 3.82, 1),
    (103, '23001575', 'Le Hoang Cuong',   'cuong.lh@sv.edu.vn', 2023, 2.95, 1),
    (104, '23001801', 'Pham Ngoc Diep',   'diep.pn@sv.edu.vn',  2023, 3.55, 2),
    (105, '23001802', 'Do Minh Giang',    'giang.dm@sv.edu.vn', 2023, 3.10, 2),
    (106, '24002101', 'Vo Khanh Huyen',   'huyen.vk@sv.edu.vn', 2024, 3.74, 3),
    (107, '24002102', 'Bui Duc Khai',     'khai.bd@sv.edu.vn',  2024, NULL, 3);

INSERT INTO courses (course_id, course_code, course_name, credits, dept_id, lecturer_id) VALUES
    (10, 'INT2204', 'Co so du lieu',               3, 1, 1),
    (11, 'INT3306', 'Phat trien ung dung Web',     3, 1, 2),
    (12, 'MAT2400', 'Xac suat thong ke',           4, 2, 3),
    (13, 'DSC3001', 'Khai pha du lieu',            3, 3, 4),
    (14, 'INT4099', 'Dien toan dam may (Chua mo)', 3, 1, 1);

INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, score) VALUES
    (1,  101, 10, '2025-1', 9.20),
    (2,  101, 11, '2025-1', 8.50),
    (3,  102, 10, '2025-1', 9.50),
    (4,  102, 13, '2025-1', 8.80),
    (5,  103, 10, '2025-1', 7.10),
    (6,  104, 12, '2025-1', 9.00),
    (7,  104, 10, '2025-1', 8.40),
    (8,  105, 12, '2025-1', 7.60),
    (9,  106, 13, '2025-1', 9.10),
    (10, 106, 10, '2025-2', NULL);
