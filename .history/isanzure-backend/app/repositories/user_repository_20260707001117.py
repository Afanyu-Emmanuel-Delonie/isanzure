import psycopg2
from config import settings

def get_db_connection():
    return psycopg2.connect(settings.DATABASE_URL)

def create_user(email, password_hash):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO users (email, password_hash) VALUES (%s, %s) RETURNING id;",
                (email, password_hash)
            )
            return cur.fetchone()[0]