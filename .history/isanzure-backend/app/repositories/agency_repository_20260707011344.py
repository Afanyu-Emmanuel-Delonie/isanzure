from app.repositories.user_repository import get_db_connection


def create_agency(name, contact_email, owner_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO agencies (name, contact_email, owner_id)
                VALUES (%s, %s, %s)
                RETURNING id, name, contact_email, owner_id, created_at;
                """,
                (name, contact_email, owner_id)
            )
            conn.commit()
            return cur.fetchone()


def get_agency_by_id(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, contact_email, owner_id, created_at FROM agencies WHERE id = %s;",
                (agency_id,)
            )
            return cur.fetchone()


def get_agency_by_owner(owner_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, contact_email, owner_id, created_at FROM agencies WHERE owner_id = %s;",
                (owner_id,)
            )
            return cur.fetchone()

def get_agency_members(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, email, phone_number, role, agency_role FROM users WHERE agency_id = %s;",
                (agency_id,)
            )
            return cur.fetchall()


