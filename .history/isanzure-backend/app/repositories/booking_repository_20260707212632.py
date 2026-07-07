from app.repositories.user_repository import get_db_connection

def create_booking(user_id, agency_id, service_id, booking_date, status):