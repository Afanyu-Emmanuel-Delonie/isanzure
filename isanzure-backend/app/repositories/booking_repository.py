from app.repositories.user_repository import get_db_connection


# ── Schedules ─────────────────────────────────────────────────────────────────

def create_schedule(bus_id, route_id, departure_time):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO schedules (bus_id, route_id, departure_time)
                VALUES (%s, %s, %s)
                RETURNING id, bus_id, route_id, departure_time, created_at;
                """,
                (bus_id, route_id, departure_time)
            )
            conn.commit()
            return cur.fetchone()


def get_schedules_by_route(route_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT s.id, s.departure_time, s.created_at,
                       r.origin, r.destination, r.price,
                       b.plate_number, b.capacity,
                       a.id AS agency_id, a.name AS agency_name
                FROM schedules s
                JOIN routes r ON r.id = s.route_id
                JOIN buses b ON b.id = s.bus_id
                JOIN agencies a ON a.id = b.agency_id
                WHERE s.route_id = %s
                ORDER BY s.departure_time;
                """,
                (route_id,)
            )
            return cur.fetchall()


def get_schedules_by_agency(agency_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT s.id, s.departure_time, s.created_at,
                       r.origin, r.destination, r.price,
                       b.plate_number, b.capacity
                FROM schedules s
                JOIN routes r ON r.id = s.route_id
                JOIN buses b ON b.id = s.bus_id
                WHERE b.agency_id = %s
                ORDER BY s.departure_time;
                """,
                (agency_id,)
            )
            return cur.fetchall()


def get_schedule_by_id(schedule_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT s.id, s.departure_time, s.created_at,
                       r.origin, r.destination, r.price,
                       b.plate_number, b.capacity,
                       a.id AS agency_id, a.name AS agency_name
                FROM schedules s
                JOIN routes r ON r.id = s.route_id
                JOIN buses b ON b.id = s.bus_id
                JOIN agencies a ON a.id = b.agency_id
                WHERE s.id = %s;
                """,
                (schedule_id,)
            )
            return cur.fetchone()


def get_booked_seats(schedule_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT seat_number FROM bookings WHERE schedule_id = %s;",
                (schedule_id,)
            )
            return [row[0] for row in cur.fetchall()]


# ── Bookings ──────────────────────────────────────────────────────────────────

def create_booking(user_id, schedule_id, seat_number):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO bookings (user_id, schedule_id, seat_number)
                VALUES (%s, %s, %s)
                RETURNING id, user_id, schedule_id, seat_number, created_at;
                """,
                (user_id, schedule_id, seat_number)
            )
            conn.commit()
            return cur.fetchone()


def get_bookings_by_user(user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT bk.id, bk.seat_number, bk.created_at,
                       s.departure_time,
                       r.origin, r.destination, r.price,
                       b.plate_number,
                       a.name AS agency_name
                FROM bookings bk
                JOIN schedules s ON s.id = bk.schedule_id
                JOIN routes r ON r.id = s.route_id
                JOIN buses b ON b.id = s.bus_id
                JOIN agencies a ON a.id = b.agency_id
                WHERE bk.user_id = %s
                ORDER BY bk.created_at DESC;
                """,
                (user_id,)
            )
            return cur.fetchall()


def get_bookings_by_schedule(schedule_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT bk.id, bk.seat_number, bk.created_at,
                       u.id AS user_id, u.name, u.email, u.phone_number
                FROM bookings bk
                JOIN users u ON u.id = bk.user_id
                WHERE bk.schedule_id = %s
                ORDER BY bk.seat_number;
                """,
                (schedule_id,)
            )
            return cur.fetchall()


def get_booking_by_id(booking_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT bk.id, bk.seat_number, bk.created_at,
                       bk.user_id, bk.schedule_id,
                       s.departure_time,
                       r.origin, r.destination, r.price,
                       b.plate_number,
                       a.name AS agency_name
                FROM bookings bk
                JOIN schedules s ON s.id = bk.schedule_id
                JOIN routes r ON r.id = s.route_id
                JOIN buses b ON b.id = s.bus_id
                JOIN agencies a ON a.id = b.agency_id
                WHERE bk.id = %s;
                """,
                (booking_id,)
            )
            return cur.fetchone()


def cancel_booking(booking_id, user_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM bookings WHERE id = %s AND user_id = %s RETURNING id;",
                (booking_id, user_id)
            )
            conn.commit()
            return cur.fetchone()
