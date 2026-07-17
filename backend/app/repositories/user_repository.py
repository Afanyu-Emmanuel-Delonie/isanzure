import psycopg2
import psycopg2.pool
from config import settings
from contextlib import contextmanager

#Initialization of pool once the app startsup
db_pool = psycopg2.pool.SimpleConnectionPool(1, 20, settings.DATABASE_URL)
@contextmanager
def get_db_connection():
    conn = db_pool.getconn()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        db_pool.putconn(conn)


def cleanup_expired_tokens():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM otp_verifications WHERE expires_at < NOW();")
            cur.execute("UPDATE users SET reset_token = NULL, reset_token_expires = NULL WHERE reset_token_expires < NOW();")


def create_user(name, email, phone, password_hash, role='passenger'):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO users (name, email, phone_number, password_hash, role) 
                VALUES (%s, %s, %s, %s, %s) 
                ON CONFLICT (email) DO NOTHING 
                RETURNING id;
                """,
                (name, email, phone, password_hash, role)
            )
            result = cur.fetchone()
            if result:
                return result[0]
            raise ValueError("A user with this email already exists.")

def save_otp(email, otp_hash, expires_at):
    cleanup_expired_tokens()
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO otp_verifications (email, otp_hash, expires_at) VALUES (%s, %s, %s);",
                (email, otp_hash, expires_at)
            )

def get_latest_otp(email):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT otp_hash, expires_at FROM otp_verifications WHERE email = %s ORDER BY created_at DESC LIMIT 1;",
                (email,)
            )
            return cur.fetchone()

def delete_otp(email):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM otp_verifications WHERE email = %s;", (email,))
            

def get_user_by_email(email):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name, email, password_hash, role FROM users WHERE email = %s;", (email,))
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
    cleanup_expired_tokens()
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET reset_token = %s, reset_token_expires = %s WHERE email = %s;",
                (token, expires_at, email)
            )


def update_password(user_id, password_hash):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET password_hash = %s, reset_token = NULL, reset_token_expires = NULL WHERE id = %s;",
                (password_hash, user_id)
            )


def update_profile(user_id, name, phone):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE users SET name = %s, phone_number = %s WHERE id = %s RETURNING id, name, email, phone_number, role;",
                (name, phone, user_id)
            )
            return cur.fetchone()
