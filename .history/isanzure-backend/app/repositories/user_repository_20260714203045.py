import psycopg2
from config import settings
from contextlib import contextmanager

#Initialization of pool once the app startsup
db_pool = psycopg2.pool.SimppleConnectionPool(1, 20, settings.DATABASE_URL)
@contextmanager
def get_db_connection():
    conn = db_pool.get
    return psycopg2.connect(settings.DATABASE_URL)


def create_user(name, email, phone, password_hash, role='passenger'):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO users (name, email, phone_number, password_hash, role) VALUES (%s, %s, %s, %s, %s) RETURNING id;",
                (name, email, phone, password_hash, role)
            )
            return cur.fetchone()[0]


def get_user_by_email(email):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, email, password_hash, role FROM users WHERE email = %s;", (email,))
            return cur.fetchone()


def get_user_by_id(user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name, email, phone_number, role, agency_id, created_at FROM users WHERE id = %s;", (user_id,))
            return cur.fetchone()


def get_user_by_reset_token(token):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, email FROM users WHERE reset_token = %s AND reset_token_expires > NOW();",
                (token,)
            )
            return cur.fetchone()


def update_reset_token(email, token, expires_at):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET reset_token = %s, reset_token_expires = %s WHERE email = %s;",
                (token, expires_at, email)
            )
            conn.commit()


def update_password(user_id, password_hash):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET password_hash = %s, reset_token = NULL, reset_token_expires = NULL WHERE id = %s;",
                (password_hash, user_id)
            )
            conn.commit()


def update_profile(user_id, name, phone):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET name = %s, phone_number = %s WHERE id = %s RETURNING id, name, email, phone_number, role;",
                (name, phone, user_id)
            )
            conn.commit()
            return cur.fetchone()
