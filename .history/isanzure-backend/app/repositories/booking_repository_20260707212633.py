from app.repositories.user_repository import get_db_connection

def create_booking(user_id, agency_id, service_id, booking_date, status):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO bookings (user_id, agency_id, service_id, booking_date, status)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id, user_id, agency_id, service_id, booking_date, status, created_at;
                """,
                (user_id, agency_id, service_id, booking_date, status)
            )
            conn.commit()
            return cur.fetchone()