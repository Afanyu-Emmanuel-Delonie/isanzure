import os
import sys
import uuid
import psycopg2
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

# Add backend directory to sys.path so we can import from app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

load_dotenv()

def seed_database():
    conn = None
    try:
        conn = psycopg2.connect(os.getenv("DATABASE_URL"))
        cursor = conn.cursor()

        # Seed Agencies
        agencies = [
            ("Volcano Express", "info@volcano.rw"),
            ("Ritco", "contact@ritco.rw"),
            ("Horizon Express", "info@horizon.rw")
        ]
        
        agency_ids = []
        for name, email in agencies:
            cursor.execute(
                "INSERT INTO agencies (id, name, contact_email) VALUES (%s, %s, %s) ON CONFLICT (contact_email) DO NOTHING RETURNING id",
                (str(uuid.uuid4()), name, email)
            )
            res = cursor.fetchone()
            if res:
                agency_ids.append(res[0])
            else:
                cursor.execute("SELECT id FROM agencies WHERE contact_email = %s", (email,))
                agency_ids.append(cursor.fetchone()[0])
        
        print(f"Seeded {len(agency_ids)} agencies.")

        # Seed Buses
        buses = [
            ("RAA 123 A", 30, agency_ids[0]),
            ("RAB 456 B", 35, agency_ids[0]),
            ("RAC 789 C", 40, agency_ids[1]),
            ("RAD 012 D", 45, agency_ids[1]),
            ("RAE 345 E", 30, agency_ids[2]),
            ("RAF 678 F", 35, agency_ids[2])
        ]
        
        bus_ids = []
        for plate, capacity, agency_id in buses:
            cursor.execute(
                "INSERT INTO buses (id, plate_number, capacity, status, agency_id) VALUES (%s, %s, %s, 'active', %s) ON CONFLICT (plate_number) DO NOTHING RETURNING id",
                (str(uuid.uuid4()), plate, capacity, agency_id)
            )
            res = cursor.fetchone()
            if res:
                bus_ids.append(res[0])
            else:
                cursor.execute("SELECT id FROM buses WHERE plate_number = %s", (plate,))
                bus_ids.append(cursor.fetchone()[0])

        print(f"Seeded {len(bus_ids)} buses.")

        # Seed Routes
        routes = [
            ("Kigali", "Musanze", 3000),
            ("Musanze", "Kigali", 3000),
            ("Kigali", "Rubavu", 4000),
            ("Rubavu", "Kigali", 4000),
            ("Kigali", "Huye", 3500),
            ("Huye", "Kigali", 3500)
        ]

        route_ids = []
        for origin, destination, price in routes:
            # Check if route already exists
            cursor.execute("SELECT id FROM routes WHERE origin = %s AND destination = %s", (origin, destination))
            res = cursor.fetchone()
            if not res:
                cursor.execute(
                    "INSERT INTO routes (id, origin, destination, price) VALUES (%s, %s, %s, %s) RETURNING id",
                    (str(uuid.uuid4()), origin, destination, price)
                )
                route_ids.append(cursor.fetchone()[0])
            else:
                route_ids.append(res[0])

        print(f"Seeded {len(route_ids)} routes.")

        # Seed Users
        cursor.execute(
            "INSERT INTO users (id, email, password_hash, name, phone_number, role) VALUES (%s, %s, %s, %s, %s, %s) ON CONFLICT (email) DO NOTHING RETURNING id",
            (str(uuid.uuid4()), "test@example.com", "hashed_password", "Test Passenger", "+250788123456", "passenger")
        )
        res = cursor.fetchone()
        if res:
            user_id = res[0]
        else:
            cursor.execute("SELECT id FROM users WHERE email = %s", ("test@example.com",))
            user_id = cursor.fetchone()[0]
        print("Seeded test passenger.")

        # Seed Schedules
        now = datetime.now(timezone.utc)
        schedules_data = [
            # Past schedule
            (bus_ids[0], route_ids[0], now - timedelta(days=2)),
            # Upcoming schedule
            (bus_ids[1], route_ids[1], now + timedelta(days=2)),
            # Another past schedule
            (bus_ids[2], route_ids[2], now - timedelta(days=5))
        ]
        
        schedule_ids = []
        for bus_id, route_id, dep_time in schedules_data:
            cursor.execute(
                "INSERT INTO schedules (id, bus_id, route_id, departure_time) VALUES (%s, %s, %s, %s) RETURNING id",
                (str(uuid.uuid4()), bus_id, route_id, dep_time)
            )
            schedule_ids.append(cursor.fetchone()[0])
            
        # Update available seats for schedules
        cursor.execute(
            "UPDATE schedules SET available_seats = buses.capacity FROM buses WHERE schedules.bus_id = buses.id"
        )
        print(f"Seeded {len(schedule_ids)} schedules.")

        # Seed Bookings
        bookings_data = [
            (user_id, schedule_ids[0], 5, "completed", "REF12345"), # Past
            (user_id, schedule_ids[1], 12, "pending", "REF67890"),  # Upcoming
            (user_id, schedule_ids[2], 1, "cancelled", "REF54321")  # Past Cancelled
        ]
        
        booking_ids = []
        for uid, sid, seat, status, ref in bookings_data:
            cursor.execute(
                "INSERT INTO bookings (id, user_id, schedule_id, seat_number, status, payment_reference) VALUES (%s, %s, %s, %s, %s, %s) ON CONFLICT (schedule_id, seat_number) DO NOTHING RETURNING id",
                (str(uuid.uuid4()), uid, sid, seat, status, ref)
            )
            res = cursor.fetchone()
            if res:
                booking_ids.append(res[0])
                # decrease available seats
                cursor.execute("UPDATE schedules SET available_seats = available_seats - 1 WHERE id = %s", (sid,))
        print(f"Seeded {len(booking_ids)} bookings.")

        conn.commit()
        print("Database successfully seeded!")

    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error seeding database: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

if __name__ == "__main__":
    seed_database()
