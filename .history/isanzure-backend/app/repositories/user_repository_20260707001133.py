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

def get_user_by_email(email):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, email, password_hash FROM users WHERE email = %s;", (email,))
            return cur.fetchone()

def update_reset_token(email, token, expires_at):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET reset_token = %s, reset_token_expires = %s WHERE email = %s;",
                (token, expires_at, email)
            )
            conn.commit()