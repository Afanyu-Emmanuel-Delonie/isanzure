from flask import Blueprint, request, jsonify, send_file
from app.repositories.booking_repository import (
    create_schedule, get_schedule_by_id, get_schedules_by_route,
    get_schedules_by_agency, get_booked_seats,
    create_booking, get_booking_by_id, get_bookings_by_user,
    get_bookings_by_schedule, cancel_booking
)
from app.repositories.user_repository import get_user_by_id
from app.utils.auth_utils import token_required, roles_required
from app.services.ticket_service import generate_ticket_pdf, verify_ticket_token

booking_bp = Blueprint('booking', __name__)


def _serialize_schedule(s):
    return {
        "id":             str(s[0]),
        "departure_time": s[1].isoformat(),
        "created_at":     s[2].isoformat(),
        "origin":         s[3],
        "destination":    s[4],
        "price":          float(s[5]),
        "plate_number":   s[6],
        "capacity":       s[7],
        "agency_id":      str(s[8]),
        "agency_name":    s[9]
    }


def _serialize_schedule_agency(s):
    return {
        "id":             str(s[0]),
        "departure_time": s[1].isoformat(),
        "created_at":     s[2].isoformat(),
        "origin":         s[3],
        "destination":    s[4],
        "price":          float(s[5]),
        "plate_number":   s[6],
        "capacity":       s[7]
    }


def _serialize_booking_user(b):
    return {
        "id":             str(b[0]),
        "seat_number":    b[1],
        "created_at":     b[2].isoformat(),
        "departure_time": b[3].isoformat(),
        "origin":         b[4],
        "destination":    b[5],
        "price":          float(b[6]),
        "plate_number":   b[7],
        "agency_name":    b[8]
    }


# ── Schedules ─────────────────────────────────────────────────────────────────

@booking_bp.route('/schedules', methods=['POST'])
@roles_required('super_admin', 'agency_admin')
def create_schedule_endpoint(current_user_id):
    data = request.json or {}
    missing = [f for f in ('bus_id', 'route_id', 'departure_time') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    # agency_admin can only assign buses that belong to their agency
    user = get_user_by_id(current_user_id)
    if user[4] == 'agency_admin' and not user[5]:
        return jsonify({"error": "You are not associated with any agency."}), 403

    schedule = create_schedule(data['bus_id'], data['route_id'], data['departure_time'])
    return jsonify(_serialize_schedule(get_schedule_by_id(schedule[0]))), 201


@booking_bp.route('/routes/<route_id>/schedules', methods=['GET'])
@token_required
def list_schedules_by_route(current_user_id, route_id):
    schedules = get_schedules_by_route(route_id)
    return jsonify([_serialize_schedule(s) for s in schedules]), 200


@booking_bp.route('/agencies/<agency_id>/schedules', methods=['GET'])
@roles_required('super_admin', 'agency_admin')
def list_schedules_by_agency(current_user_id, agency_id):
    user = get_user_by_id(current_user_id)
    if user[4] != 'super_admin' and str(user[5]) != agency_id:
        return jsonify({"error": "Forbidden: You cannot access other agencies."}), 403

    schedules = get_schedules_by_agency(agency_id)
    return jsonify([_serialize_schedule_agency(s) for s in schedules]), 200


@booking_bp.route('/schedules/<schedule_id>', methods=['GET'])
@token_required
def get_schedule(current_user_id, schedule_id):
    schedule = get_schedule_by_id(schedule_id)
    if not schedule:
        return jsonify({"error": "Schedule not found."}), 404

    booked = get_booked_seats(schedule_id)
    result = _serialize_schedule(schedule)
    result['booked_seats'] = booked
    result['available_seats'] = schedule[7] - len(booked)
    return jsonify(result), 200


# ── Bookings ──────────────────────────────────────────────────────────────────

@booking_bp.route('/bookings', methods=['POST'])
@token_required
def book_seat(current_user_id):
    data = request.json or {}
    missing = [f for f in ('schedule_id', 'seat_number') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    seat = data['seat_number']
    if not isinstance(seat, int) or seat <= 0:
        return jsonify({"error": "seat_number must be a positive integer."}), 400

    try:
        booking = create_booking(current_user_id, data['schedule_id'], seat)
    except Exception as e:
        if hasattr(e, 'pgcode') and e.pgcode == '23505':
            return jsonify({"error": "Seat already booked."}), 409
        return jsonify({"error": "Could not complete booking."}), 400

    full = get_booking_by_id(booking[0])
    return jsonify({
        "id":             str(full[0]),
        "seat_number":    full[1],
        "created_at":     full[2].isoformat(),
        "user_id":        str(full[3]),
        "schedule_id":    str(full[4]),
        "departure_time": full[5].isoformat(),
        "origin":         full[6],
        "destination":    full[7],
        "price":          float(full[8]),
        "plate_number":   full[9],
        "agency_name":    full[10]
    }), 201


@booking_bp.route('/bookings/me', methods=['GET'])
@token_required
def my_bookings(current_user_id):
    bookings = get_bookings_by_user(current_user_id)
    return jsonify([_serialize_booking_user(b) for b in bookings]), 200


@booking_bp.route('/bookings/<booking_id>', methods=['GET'])
@token_required
def get_booking(current_user_id, booking_id):
    booking = get_booking_by_id(booking_id)
    if not booking:
        return jsonify({"error": "Booking not found."}), 404

    user = get_user_by_id(current_user_id)
    if user[4] not in ('super_admin', 'agency_admin') and str(booking[3]) != current_user_id:
        return jsonify({"error": "Forbidden."}), 403

    return jsonify({
        "id":             str(booking[0]),
        "seat_number":    booking[1],
        "created_at":     booking[2].isoformat(),
        "user_id":        str(booking[3]),
        "schedule_id":    str(booking[4]),
        "departure_time": booking[5].isoformat(),
        "origin":         booking[6],
        "destination":    booking[7],
        "price":          float(booking[8]),
        "plate_number":   booking[9],
        "agency_name":    booking[10]
    }), 200


@booking_bp.route('/schedules/<schedule_id>/bookings', methods=['GET'])
@roles_required('super_admin', 'agency_admin')
def list_schedule_bookings(current_user_id, schedule_id):
    schedule = get_schedule_by_id(schedule_id)
    if not schedule:
        return jsonify({"error": "Schedule not found."}), 404

    user = get_user_by_id(current_user_id)
    if user[4] != 'super_admin' and str(user[5]) != str(schedule[8]):
        return jsonify({"error": "Forbidden: You cannot access other agencies."}), 403

    bookings = get_bookings_by_schedule(schedule_id)
    return jsonify([
        {
            "id":          str(b[0]),
            "seat_number": b[1],
            "created_at":  b[2].isoformat(),
            "user_id":     str(b[3]),
            "name":        b[4],
            "email":       b[5],
            "phone":       b[6]
        }
        for b in bookings
    ]), 200


# ── Tickets ───────────────────────────────────────────────────────────────────

@booking_bp.route('/bookings/<booking_id>/ticket', methods=['GET'])
@token_required
def download_ticket(current_user_id, booking_id):
    booking = get_booking_by_id(booking_id)
    if not booking:
        return jsonify({"error": "Booking not found."}), 404

    user = get_user_by_id(current_user_id)
    if user[4] not in ('super_admin', 'agency_admin') and str(booking[3]) != current_user_id:
        return jsonify({"error": "Forbidden."}), 403

    booking_dict = {
        "id":             str(booking[0]),
        "seat_number":    booking[1],
        "created_at":     booking[2].isoformat(),
        "user_id":        str(booking[3]),
        "schedule_id":    str(booking[4]),
        "departure_time": booking[5].strftime("%d %b %Y, %H:%M"),
        "origin":         booking[6],
        "destination":    booking[7],
        "price":          float(booking[8]),
        "plate_number":   booking[9],
        "agency_name":    booking[10],
    }

    pdf_buf = generate_ticket_pdf(booking_dict, user[1], user[2])
    filename = f"ticket-{booking_id[:8]}.pdf"
    return send_file(pdf_buf, mimetype="application/pdf",
                     as_attachment=True, download_name=filename)


@booking_bp.route('/bookings/<booking_id>/verify', methods=['GET'])
@roles_required('super_admin', 'agency_admin')
def verify_ticket(current_user_id, booking_id):
    token = request.args.get('token')
    if not token:
        return jsonify({"error": "Missing token query parameter."}), 400

    payload = verify_ticket_token(token)
    if not payload:
        return jsonify({"valid": False, "error": "Invalid or tampered ticket."}), 400

    if payload.get('booking_id') != booking_id:
        return jsonify({"valid": False, "error": "Token does not match this booking."}), 400

    booking = get_booking_by_id(booking_id)
    if not booking:
        return jsonify({"valid": False, "error": "Booking not found."}), 404

    return jsonify({
        "valid":          True,
        "booking_id":     str(booking[0]),
        "seat_number":    booking[1],
        "departure_time": booking[5].isoformat(),
        "origin":         booking[6],
        "destination":    booking[7],
        "plate_number":   booking[9],
        "agency_name":    booking[10],
        "user_id":        str(booking[3]),
    }), 200


@booking_bp.route('/bookings/<booking_id>', methods=['DELETE'])
@token_required
def cancel_booking_endpoint(current_user_id, booking_id):
    booking = get_booking_by_id(booking_id)
    if not booking:
        return jsonify({"error": "Booking not found."}), 404

    if str(booking[3]) != current_user_id:
        return jsonify({"error": "Forbidden: You can only cancel your own bookings."}), 403

    result = cancel_booking(booking_id, current_user_id)
    if not result:
        return jsonify({"error": "Could not cancel booking."}), 400

    return jsonify({"message": "Booking cancelled successfully."}), 200
