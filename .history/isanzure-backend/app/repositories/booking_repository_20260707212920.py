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
        
def get_booking_by_id(booking_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, user_id, schedule_id, seat_number, created_at 
                FROM bookings WHERE id = %s;
            """, (booking_id,))
            return cur.fetchone()
        
def get_bookings_by_user(user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, user_id, schedule_id, seat_number, created_at 
                FROM bookings WHERE user_id = %s;
            """, (user_id,))
            return cur.fetchall()
        
