import psycopg2
from config import settings

conn = psycopg2.connect(settings.DATABASE_URL)
conn.autocommit = True
cur = conn.cursor()

cur.execute("DELETE FROM otp_verifications;")
cur.execute("DELETE FROM bookings;")
cur.execute("DELETE FROM users;")

print("All users, bookings, and OTPs cleared.")
cur.close()
conn.close()
