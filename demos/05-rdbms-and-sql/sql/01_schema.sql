-- =============================================================================
-- 01_schema.sql - DDL: Khởi tạo lược đồ CSDL Quản lý Đào tạo Đại học
-- Tương thích chuẩn ANSI SQL trên PostgreSQL, MariaDB/MySQL và SQLite 3.39+
-- Ghi chú về khóa tự tăng (Auto-Increment) giữa các RDBMS:
--   - PostgreSQL : INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY (hoặc SERIAL)
--   - MySQL/MariaDB : INT AUTO_INCREMENT PRIMARY KEY
--   - SQLite     : INTEGER PRIMARY KEY AUTOINCREMENT
-- Ở bài demo này dùng INT PRIMARY KEY tường minh để chạy đồng nhất trên cả 3 hệ.
-- =============================================================================

DROP VIEW IF EXISTS v_student_transcript;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS lecturers;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id   INT          PRIMARY KEY,
    dept_code VARCHAR(10)  NOT NULL UNIQUE,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE lecturers (
    lecturer_id INT          PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(120) NOT NULL UNIQUE,
    dept_id     INT          NOT NULL,
    CONSTRAINT fk_lecturers_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE students (
    student_id   INT          PRIMARY KEY,
    student_code VARCHAR(12)  NOT NULL UNIQUE,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    cohort_year  INT          NOT NULL CHECK (cohort_year >= 2000),
    gpa          DECIMAL(3,2) CHECK (gpa IS NULL OR (gpa >= 0.00 AND gpa <= 4.00)),
    dept_id      INT          NOT NULL,
    CONSTRAINT fk_students_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE courses (
    course_id   INT          PRIMARY KEY,
    course_code VARCHAR(12)  NOT NULL UNIQUE,
    course_name VARCHAR(120) NOT NULL,
    credits     INT          NOT NULL CHECK (credits BETWEEN 1 AND 6),
    dept_id     INT          NOT NULL,
    lecturer_id INT,
    CONSTRAINT fk_courses_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    CONSTRAINT fk_courses_lecturer
        FOREIGN KEY (lecturer_id) REFERENCES lecturers(lecturer_id)
);

CREATE TABLE enrollments (
    enrollment_id INT         PRIMARY KEY,
    student_id    INT         NOT NULL,
    course_id     INT         NOT NULL,
    semester      VARCHAR(16) NOT NULL,
    score         DECIMAL(4,2) CHECK (score IS NULL OR (score >= 0.00 AND score <= 10.00)),
    CONSTRAINT uq_student_course_sem UNIQUE (student_id, course_id, semester),
    CONSTRAINT fk_enroll_student
        FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_enroll_course
        FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE INDEX idx_students_dept ON students(dept_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
