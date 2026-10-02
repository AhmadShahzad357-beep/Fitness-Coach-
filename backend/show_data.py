"""Print what FitCoach has saved in the local SQLite database (fitcoach.db).

Run from anywhere:  python backend/show_data.py  (or use show-data.ps1)
Password hashes are never printed.
"""

import sqlite3
import sys
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "fitcoach.db"

# table -> columns to show (password_hash deliberately left out)
TABLES = {
    "users": "id, username, timezone, created_at",
    "profiles": "user_id, name, age, gender, height_cm, weight_kg, goal, activity_level",
    "weight_logs": "id, user_id, logged_on, weight_kg",
    "meal_logs": "id, user_id, logged_on, food, calories",
    "workout_logs": "id, user_id, logged_on, exercise, sets, reps, weight_kg",
    "reminders": "id, user_id, time_hhmm, message, active, last_fired_on",
    "notifications": "id, user_id, message, created_at, read_at",
    "chat_messages": "id, user_id, role, substr(content, 1, 80) AS content, tool_name, created_at",
}
LAST_N = 10


def main() -> None:
    sys.stdout.reconfigure(errors="replace")  # Windows consoles cannot print every character
    if not DB_PATH.exists():
        sys.exit(f"No database at {DB_PATH}. Run setup.ps1 (or alembic upgrade head) first.")
    con = sqlite3.connect(DB_PATH)
    for table, cols in TABLES.items():
        try:
            total = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]  # noqa: S608
            cur = con.execute(f"SELECT {cols} FROM {table} ORDER BY rowid DESC LIMIT {LAST_N}")  # noqa: S608
        except sqlite3.OperationalError as exc:
            print(f"\n== {table}: {exc} (run the migrations)")
            continue
        headers = [d[0] for d in cur.description]
        rows = cur.fetchall()
        print(f"\n== {table}  ({total} rows, showing last {len(rows)})")
        if rows:
            print("  " + " | ".join(headers))
            for row in rows:
                print("  " + " | ".join("" if v is None else str(v) for v in row))
    con.close()


if __name__ == "__main__":
    main()
