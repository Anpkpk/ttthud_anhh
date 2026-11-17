-- =============================================================================
-- 04_tcl_and_views.sql - VIEW và kiểm chứng Transaction (ROLLBACK / COMMIT)
-- =============================================================================

-- [V1] Tạo VIEW tổng hợp bảng điểm phục vụ tái sử dụng truy vấn
CREATE VIEW v_student_transcript AS
SELECT s.student_code,
       s.full_name AS student_name,
       d.dept_code,
       c.course_code,
       c.course_name,
       e.semester,
       e.score
FROM enrollments e
JOIN students    s ON e.student_id = s.student_id
JOIN departments d ON s.dept_id    = d.dept_id
JOIN courses     c ON e.course_id  = c.course_id;

-- Truy vấn dữ liệu từ VIEW vừa tạo
SELECT student_code, student_name, course_code, score
FROM v_student_transcript
WHERE score >= 8.50
ORDER BY score DESC, student_code ASC;
