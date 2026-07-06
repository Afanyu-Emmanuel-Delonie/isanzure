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


def create_review(agency_id, user_id, booking_id, rating, comment):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO reviews (agency_id, user_id, booking_id, rating, comment)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id, agency_id, user_id, booking_id, rating, comment, created_at;
                """,
                (agency_id, user_id, booking_id, rating, comment)
            )
            conn.commit()
            return cur.fetchone()

def create_bus(plate_number, capacity, agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO buses (plate_number, capacity, agency_id) VALUES (%s, %s, %s) RETURNING id;",
                (plate_number, capacity, agency_id)
            )
            return cur.fetchone()[0]

def get_buses_by_agency(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, plate_number, capacity, status FROM buses WHERE agency_id = %s;",
                (agency_id,)
            )
            return cur.fetchall()

def get_reviews_by_agency(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT r.id, r.rating, r.comment, r.created_at, u.name AS reviewer
                FROM reviews r
                JOIN users u ON u.id = r.user_id
                WHERE r.agency_id = %s
                ORDER BY r.created_at DESC;
                """,
                (agency_id,)
            )
            return cur.fetchall()


def get_agency_rating_summary(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT COUNT(*) AS total, ROUND(AVG(rating), 1) AS average
                FROM reviews WHERE agency_id = %s;
                """,
                (agency_id,)
            )
            return cur.fetchone()
