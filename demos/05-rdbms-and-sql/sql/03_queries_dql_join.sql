-- =============================================================================
-- 03_queries_dql_join.sql - DQL: 10 truy vấn SQL từ cơ bản đến nâng cao
-- =============================================================================

-- [Q1] Lọc & sắp xếp: Sinh viên khóa 2023 có GPA >= 3.20
SELECT student_code, full_name, gpa
FROM students
WHERE cohort_year = 2023 AND gpa >= 3.20
ORDER BY gpa DESC, student_code ASC;

-- [Q2] Xử lý NULL: Tìm sinh viên chưa có GPA và thay bằng giá trị mặc định bằng COALESCE
SELECT student_code,
       full_name,
       gpa                    AS raw_gpa,
       COALESCE(gpa, 0.00)    AS gpa_with_default
FROM students
WHERE gpa IS NULL;

-- [Q3] INNER JOIN nhiều bảng: Bảng điểm chi tiết kèm giảng viên phụ trách
SELECT s.student_code,
       s.full_name   AS student_name,
       c.course_code,
       c.course_name,
       l.full_name   AS lecturer_name,
       e.semester,
       e.score
FROM enrollments e
INNER JOIN students  s ON e.student_id  = s.student_id
INNER JOIN courses   c ON e.course_id   = c.course_id
LEFT  JOIN lecturers l ON c.lecturer_id = l.lecturer_id
ORDER BY s.student_code, c.course_code;

-- [Q4] GROUP BY & HAVING: Thống kê sinh viên có GPA theo từng khoa (chỉ lấy khoa có >= 2 SV có GPA)
SELECT d.dept_code,
       d.dept_name,
       COUNT(s.student_id)      AS graded_students,
       ROUND(AVG(s.gpa), 2)     AS avg_gpa,
       MAX(s.gpa)               AS max_gpa
FROM departments d
JOIN students s ON d.dept_id = s.dept_id
WHERE s.gpa IS NOT NULL
GROUP BY d.dept_id, d.dept_code, d.dept_name
HAVING COUNT(s.student_id) >= 2
ORDER BY avg_gpa DESC;

-- [Q5] LEFT JOIN tìm dữ liệu thiếu: Môn học chưa có sinh viên nào đăng ký
SELECT c.course_code, c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- [Q6] LEFT JOIN thống kê: Tổng số môn & tổng tín chỉ đã đăng ký của TẤT CẢ sinh viên
SELECT s.student_code,
       s.full_name,
       COUNT(e.enrollment_id)            AS total_courses,
       COALESCE(SUM(c.credits), 0)       AS total_credits
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses     c ON e.course_id  = c.course_id
GROUP BY s.student_id, s.student_code, s.full_name
ORDER BY total_courses DESC, s.student_code ASC;

-- [Q7] Biểu thức điều kiện CASE WHEN: Xếp loại học lực theo GPA
SELECT student_code,
       full_name,
       gpa,
       CASE
           WHEN gpa IS NULL THEN 'Chua xep loai'
           WHEN gpa >= 3.60 THEN 'Xuat sac'
           WHEN gpa >= 3.20 THEN 'Gioi'
           WHEN gpa >= 2.50 THEN 'Kha'
           ELSE 'Trung binh'
       END AS academic_rank
FROM students
ORDER BY student_code;

-- [Q8] EXISTS (Subquery tương quan): Sinh viên từng đạt ít nhất một điểm >= 9.0
SELECT s.student_code, s.full_name
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
      AND e.score >= 9.00
)
ORDER BY s.student_code;

-- [Q9] CTE (Common Table Expression): Sinh viên có GPA cao hơn trung bình của chính khoa mình
WITH dept_avg AS (
    SELECT dept_id, AVG(gpa) AS avg_dept_gpa
    FROM students
    WHERE gpa IS NOT NULL
    GROUP BY dept_id
)
SELECT s.student_code,
       s.full_name,
       d.dept_code,
       s.gpa,
       ROUND(da.avg_dept_gpa, 2) AS dept_avg_gpa
FROM students s
JOIN departments d  ON s.dept_id = d.dept_id
JOIN dept_avg    da ON s.dept_id = da.dept_id
WHERE s.gpa > da.avg_dept_gpa
ORDER BY d.dept_code, s.gpa DESC;

-- [Q10] Window Function: Xếp hạng GPA trong từng khoa mà vẫn giữ nguyên từng dòng sinh viên
SELECT d.dept_code,
       s.student_code,
       s.full_name,
       s.gpa,
       DENSE_RANK() OVER (
           PARTITION BY s.dept_id
           ORDER BY s.gpa DESC
       ) AS rank_in_dept
FROM students s
JOIN departments d ON s.dept_id = d.dept_id
WHERE s.gpa IS NOT NULL
ORDER BY d.dept_code, rank_in_dept;
