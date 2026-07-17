# app/services/booking_service.py
from app.repositories import booking_repository

class BookingService:
    
    @staticmethod
    def book_seat(user_id, schedule_id, seat_number):
        try:
            # 1. ATTEMPT ATOMIC LOCK & CREATE BOOKING RECORD
            # We use the repository's create_booking which handles both decrementing
            # available_seats and inserting the booking in one atomic transaction.
            booking = booking_repository.create_booking(user_id, schedule_id, seat_number)
            return {
                "success": True, 
                "booking_id": str(booking[0]), 
                "message": "Seat reserved successfully. Please complete payment."
            }
        except ValueError as e:
            # Handle the "No seats available on this schedule." error
            return {"success": False, "message": str(e)}
        except Exception as e:
            if hasattr(e, 'pgcode') and e.pgcode == '23505':
                return {"success": False, "message": "Seat already booked."}
            print(f"Error creating booking record: {e}")
            return {"success": False, "message": "Internal error occurred."}