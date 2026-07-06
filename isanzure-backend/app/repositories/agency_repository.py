from app.repositories.user_repository import get_db_connection


def create_agency(name, owner_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO agencies (name, owner_id) VALUES (%s, %s)
                RETURNING id, name, owner_id, created_at;
                """,
                (name, owner_id)
            )
            conn.commit()
            return cur.fetchone()


def get_agency_by_id(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, owner_id, created_at FROM agencies WHERE id = %s;",
                (agency_id,)
            )
            return cur.fetchone()


def get_agency_by_owner(owner_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, owner_id, created_at FROM agencies WHERE owner_id = %s;",
                (owner_id,)
            )
            return cur.fetchone()


def create_invitation(email, agency_id, token, expires_at):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO invitations (email, agency_id, token, expires_at)
                VALUES (%s, %s, %s, %s)
                RETURNING id, email, agency_id, status, expires_at;
                """,
                (email, agency_id, token, expires_at)
            )
            conn.commit()
            return cur.fetchone()


def get_invitation_by_token(token):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, email, agency_id, status, expires_at
                FROM invitations
                WHERE token = %s AND status = 'pending' AND expires_at > NOW();
                """,
                (token,)
            )
            return cur.fetchone()


def accept_invitation(token, user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, email, agency_id FROM invitations WHERE token = %s AND status = 'pending' AND expires_at > NOW();",
                (token,)
            )
            invitation = cur.fetchone()
            if not invitation:
                return None

            inv_id, email, agency_id = invitation

            cur.execute(
                "UPDATE users SET role = 'agency', agency_id = %s WHERE id = %s;",
                (agency_id, user_id)
            )
            cur.execute(
                "UPDATE invitations SET status = 'accepted' WHERE id = %s;",
                (inv_id,)
            )
            conn.commit()
            return agency_id


def get_agency_members(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, email, phone, role FROM users WHERE agency_id = %s;",
                (agency_id,)
            )
            return cur.fetchall()


def get_pending_invitations(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, email, status, expires_at, created_at FROM invitations WHERE agency_id = %s ORDER BY created_at DESC;",
                (agency_id,)
            )
            return cur.fetchall()
