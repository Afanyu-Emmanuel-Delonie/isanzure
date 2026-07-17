"""
Run database migrations in order.
Usage: python migrate.py
"""
import os
import psycopg2
from config import settings

MIGRATIONS_DIR = os.path.join(os.path.dirname(__file__), "database", "migrations")


def get_conn():
    return psycopg2.connect(settings.DATABASE_URL)


def ensure_migrations_table(cur):
    cur.execute("""
        CREATE TABLE IF NOT EXISTS migrations (
            id SERIAL PRIMARY KEY,
            filename VARCHAR(255) UNIQUE NOT NULL,
            applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
    """)


def get_applied(cur):
    cur.execute("SELECT filename FROM migrations;")
    return {row[0] for row in cur.fetchall()}


def run():
    conn = get_conn()
    cur = conn.cursor()

    ensure_migrations_table(cur)
    conn.commit()

    applied = get_applied(cur)
    files = sorted(f for f in os.listdir(MIGRATIONS_DIR) if f.endswith(".sql"))

    for filename in files:
        if filename in applied:
            print(f"  skipped: {filename}")
            continue

        path = os.path.join(MIGRATIONS_DIR, filename)
        with open(path, "r") as f:
            sql = f.read()

        cur.execute(sql)
        cur.execute("INSERT INTO migrations (filename) VALUES (%s);", (filename,))
        conn.commit()
        print(f"  applied: {filename}")

    cur.close()
    conn.close()
    print("Migrations complete.")


if __name__ == "__main__":
    run()
