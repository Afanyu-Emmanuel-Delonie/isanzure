from app.repositories.user_repository import get_db_connection


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
