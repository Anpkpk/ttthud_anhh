#!/usr/bin/env python3
"""
Chạy thử bộ kịch bản RDBMS & SQL (DDL, DML, DQL, VIEW, Transaction ACID)
trên SQLite tích hợp sẵn trong Python (zero-config).
"""

import argparse
import re
import sqlite3
from pathlib import Path

SQL_DIR = Path(__file__).resolve().parent / "sql"


def format_table(headers: list[str], rows: list[tuple]) -> str:
    str_rows = [[("NULL" if v is None else str(v)) for v in row] for row in rows]
    widths = [len(h) for h in headers]
    for row in str_rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], len(val))

    sep = "+-" + "-+-".join("-" * w for w in widths) + "-+"
    header_line = "| " + " | ".join(h.ljust(widths[i]) for i, h in enumerate(headers)) + " |"
    lines = [sep, header_line, sep]
    for row in str_rows:
        lines.append("| " + " | ".join(val.ljust(widths[i]) for i, val in enumerate(row)) + " |")
    lines.append(sep)
    return "\n".join(lines)


def split_labeled_queries(sql_text: str) -> list[tuple[str, str]]:
    """Tách các câu SQL có tiêu đề dạng `-- [Q1] ...` thành danh sách (title, sql)."""
    blocks: list[tuple[str, str]] = []
    current_title = "Query"
    current_lines: list[str] = []

    for line in sql_text.splitlines():
        match = re.match(r"^--\s*(\[(?:Q|V)\d+\].*)$", line.strip())
        if match:
            if current_lines:
                stmt = "\n".join(current_lines).strip()
                if stmt:
                    blocks.append((current_title, stmt))
            current_title = match.group(1)
            current_lines = []
        else:
            if not line.strip().startswith("--") or current_lines:
                current_lines.append(line)

    if current_lines:
        stmt = "\n".join(current_lines).strip()
        if stmt:
            blocks.append((current_title, stmt))
    return blocks


def strip_leading_comments(sql: str) -> str:
    lines = sql.splitlines()
    while lines and (not lines[0].strip() or lines[0].strip().startswith("--")):
        lines.pop(0)
    return "\n".join(lines).strip()


def run_view_and_queries(conn: sqlite3.Connection, view_sql: str) -> None:
    print("\n=== [VIEW] Thực thi 04_tcl_and_views.sql ===")
    for _, raw_block in split_labeled_queries(view_sql):
        for raw_stmt in raw_block.split(";"):
            stmt = strip_leading_comments(raw_stmt)
            if not stmt:
                continue
            if stmt.upper().startswith("SELECT"):
                run_select_and_print(conn, "[V1] SELECT FROM v_student_transcript", stmt)
            else:
                conn.execute(stmt)
                print("Created VIEW v_student_transcript.")


def run_select_and_print(conn: sqlite3.Connection, title: str, stmt: str) -> None:
    print(f"\n--- {title} ---")
    cur = conn.execute(stmt)
    if cur.description is None:
        print("(Executed non-SELECT statement)")
        return
    headers = [desc[0] for desc in cur.description]
    rows = cur.fetchall()
    print(format_table(headers, rows))
    print(f"({len(rows)} row(s))")


def verify_transaction_acid(conn: sqlite3.Connection) -> None:
    print("\n=== [TCL] Kiểm chứng Transaction (Atomicity: ROLLBACK & COMMIT) ===")
    before = conn.execute("SELECT student_code, gpa FROM students WHERE student_id = 107").fetchone()
    print(f"1. Trước giao dịch       : student_code={before[0]}, gpa={before[1]}")

    conn.execute("BEGIN;")
    conn.execute("UPDATE students SET gpa = 3.50 WHERE student_id = 107;")
    during = conn.execute("SELECT student_code, gpa FROM students WHERE student_id = 107").fetchone()
    print(f"2. Trong giao dịch (tạm) : student_code={during[0]}, gpa={during[1]}")

    conn.execute("ROLLBACK;")
    after_rb = conn.execute("SELECT student_code, gpa FROM students WHERE student_id = 107").fetchone()
    print(f"3. Sau ROLLBACK          : student_code={after_rb[0]}, gpa={after_rb[1]} (Khôi phục nguyên trạng!)")

    conn.execute("BEGIN;")
    conn.execute("UPDATE students SET gpa = 3.45 WHERE student_id = 107;")
    conn.execute("COMMIT;")
    after_cm = conn.execute("SELECT student_code, gpa FROM students WHERE student_id = 107").fetchone()
    print(f"4. Sau UPDATE + COMMIT   : student_code={after_cm[0]}, gpa={after_cm[1]} (Đã lưu bền vững!)")


def verify_fk_constraint(conn: sqlite3.Connection) -> None:
    print("\n=== [RDBMS Integrity] Kiểm chứng ràng buộc Foreign Key & CHECK ===")
    try:
        conn.execute(
            "INSERT INTO students (student_id, student_code, full_name, email, cohort_year, gpa, dept_id) "
            "VALUES (999, '99999999', 'Test FK', 'fk@sv.edu.vn', 2025, 3.00, 999);"
        )
        print("UNEXPECTED: FK did not reject dept_id=999")
    except sqlite3.IntegrityError as exc:
        print(f"FK blocked invalid insert as expected -> {exc}")

    try:
        conn.execute(
            "INSERT INTO students (student_id, student_code, full_name, email, cohort_year, gpa, dept_id) "
            "VALUES (999, '99999999', 'Test CHECK', 'chk@sv.edu.vn', 2025, 4.50, 1);"
        )
        print("UNEXPECTED: CHECK did not reject gpa=4.50")
    except sqlite3.IntegrityError as exc:
        print(f"CHECK blocked invalid GPA (4.50) as expected -> {exc}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Demo RDBMS & SQL với SQLite")
    parser.add_argument(
        "--db-file",
        default=":memory:",
        help="Đường dẫn tệp SQLite .db (mặc định :memory: để giữ thư mục sạch)",
    )
    args = parser.parse_args()

    print(f"=== SQLite RDBMS Demo (SQLite version {sqlite3.sqlite_version}) ===")
    # Dùng isolation_level=None để chủ động điều khiển BEGIN/COMMIT/ROLLBACK tường minh
    conn = sqlite3.connect(args.db_file, isolation_level=None)
    try:
        conn.execute("PRAGMA foreign_keys = ON;")

        schema_sql = (SQL_DIR / "01_schema.sql").read_text(encoding="utf-8")
        seed_sql = (SQL_DIR / "02_seed.sql").read_text(encoding="utf-8")
        queries_sql = (SQL_DIR / "03_queries_dql_join.sql").read_text(encoding="utf-8")
        view_sql = (SQL_DIR / "04_tcl_and_views.sql").read_text(encoding="utf-8")

        conn.executescript(schema_sql)
        print("1. Executed 01_schema.sql (DDL: 5 tables + 2 indexes)")

        conn.executescript(seed_sql)
        print("2. Executed 02_seed.sql (DML: seed data loaded)")

        verify_fk_constraint(conn)

        print("\n=== [DQL] Chạy 10 truy vấn từ 03_queries_dql_join.sql ===")
        for title, stmt in split_labeled_queries(queries_sql):
            run_select_and_print(conn, title, stmt)

        run_view_and_queries(conn, view_sql)

        verify_transaction_acid(conn)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
