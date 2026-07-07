from app.repositories.user_repository import get_db_connection

def create_booking(user_id, schedule_id, seat_number):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            # We use a transaction. If the seat is taken (UNIQUE constraint in DB), 
            # this will raise an error that we can catch.
            cur.execute("""
                INSERT INTO bookings (user_id, schedule_id, seat_number)
                VALUES (%s, %s, %s) RETURNING id;
            """, (user_id, schedule_id, seat_number))
            booking_id = cur.fetchone()[0]
            conn.commit()
            return booking_id
        
