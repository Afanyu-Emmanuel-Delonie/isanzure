from flask import Blueprint, request, jsonify
from app.repositories.agency_repository import (
    create_agency, get_agency_by_owner, get_agency_by_id, get_agency_members,
    create_bus, get_buses_by_agency,
    create_review, get_reviews_by_agency, get_agency_rating_summary
)
from app.repositories.user_repository import get_user_by_id
from app.utils.auth_utils import token_required, roles_required

agency_bp = Blueprint('agency', __name__)


def _agency_or_404(agency_id):
    agency = get_agency_by_id(agency_id)
    if not agency:
        return None, jsonify({"error": "Agency not found."}), 404
    return agency, None, None


def _assert_agency_access(user, agency_id):
    """Returns 403 response if non-super_admin accesses another agency, else None."""
    # user tuple: (id, name, email, phone_number, role, agency_id, created_at)
    if user[4] != 'super_admin' and str(user[5]) != agency_id:
        return jsonify({"error": "Forbidden: You cannot access other agencies."}), 403
    return None


# ── Agencies ──────────────────────────────────────────────────────────────────

@agency_bp.route('/agencies', methods=['POST'])
@roles_required('super_admin')
def create_agency_route(current_user_id):
    data = request.json or {}
    missing = [f for f in ('name', 'contact_email') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    agency = create_agency(data['name'], data['contact_email'], current_user_id)
    return jsonify({
        "id": str(agency[0]),
        "name": agency[1],
        "contact_email": agency[2],
        "owner_id": str(agency[3]),
        "created_at": agency[4].isoformat()
    }), 201


@agency_bp.route('/agencies/<agency_id>', methods=['GET'])
@token_required
def get_agency_route(current_user_id, agency_id):
    agency, err, code = _agency_or_404(agency_id)
    if err:
        return err, code

    return jsonify({
        "id": str(agency[0]),
        "name": agency[1],
        "contact_email": agency[2],
        "owner_id": str(agency[3]),
        "created_at": agency[4].isoformat()
    }), 200


@agency_bp.route('/agencies/mine', methods=['GET'])
@roles_required('agency_admin')
def get_my_agency(current_user_id):
    agency = get_agency_by_owner(current_user_id)
    if not agency:
        return jsonify({"error": "No agency found for this user."}), 404

    return jsonify({
        "id": str(agency[0]),
        "name": agency[1],
        "contact_email": agency[2],
        "owner_id": str(agency[3]),
        "created_at": agency[4].isoformat()
    }), 200


# ── Members ───────────────────────────────────────────────────────────────────

@agency_bp.route('/agencies/<agency_id>/members', methods=['GET'])
@roles_required('super_admin', 'agency_admin')
def list_members(current_user_id, agency_id):
    agency, err, code = _agency_or_404(agency_id)
    if err:
        return err, code

    user = get_user_by_id(current_user_id)
    err = _assert_agency_access(user, agency_id)
    if err:
        return err

    members = get_agency_members(agency_id)
    return jsonify([
        {"id": str(m[0]), "name": m[1], "email": m[2], "phone": m[3], "role": m[4], "agency_role": m[5]}
        for m in members
    ]), 200


# ── Buses ─────────────────────────────────────────────────────────────────────

@agency_bp.route('/agencies/<agency_id>/buses', methods=['POST'])
@roles_required('super_admin', 'agency_admin')
def add_bus(current_user_id, agency_id):
    agency, err, code = _agency_or_404(agency_id)
    if err:
        return err, code

    user = get_user_by_id(current_user_id)
    err = _assert_agency_access(user, agency_id)
    if err:
        return err

    data = request.json or {}
    missing = [f for f in ('plate_number', 'capacity') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    capacity = data['capacity']
    if not isinstance(capacity, int) or capacity <= 0:
        return jsonify({"error": "capacity must be a positive integer."}), 400

    bus = create_bus(data['plate_number'], capacity, agency_id)
    # bus: (id, plate_number, capacity, status, agency_id)
    return jsonify({
        "id": str(bus[0]),
        "plate_number": bus[1],
        "capacity": bus[2],
        "max_passengers": bus[2],
        "status": bus[3],
        "agency_id": str(bus[4])
    }), 201


@agency_bp.route('/agencies/<agency_id>/buses', methods=['GET'])
@roles_required('super_admin', 'agency_admin')
def list_buses(current_user_id, agency_id):
    agency, err, code = _agency_or_404(agency_id)
    if err:
        return err, code

    user = get_user_by_id(current_user_id)
    err = _assert_agency_access(user, agency_id)
    if err:
        return err

    buses = get_buses_by_agency(agency_id)
    # bus row: (id, plate_number, capacity, status)
    return jsonify([
        {"id": str(b[0]), "plate_number": b[1], "capacity": b[2], "max_passengers": b[2], "status": b[3]}
        for b in buses
    ]), 200


# ── Reviews ───────────────────────────────────────────────────────────────────

@agency_bp.route('/agencies/<agency_id>/reviews', methods=['POST'])
@token_required
def post_review(current_user_id, agency_id):
    agency, err, code = _agency_or_404(agency_id)
    if err:
        return err, code

    data = request.json or {}
    if not data.get('rating'):
        return jsonify({"error": "Missing fields: rating"}), 400

    rating = data['rating']
    if not isinstance(rating, int) or not (1 <= rating <= 5):
        return jsonify({"error": "rating must be an integer between 1 and 5."}), 400

    review = create_review(agency_id, current_user_id, data.get('booking_id'), rating, data.get('comment'))
    # review: (id, agency_id, user_id, booking_id, rating, comment, created_at)
    return jsonify({
        "id": str(review[0]),
        "agency_id": str(review[1]),
        "user_id": str(review[2]),
        "booking_id": str(review[3]) if review[3] else None,
        "rating": review[4],
        "comment": review[5],
        "created_at": review[6].isoformat()
    }), 201


@agency_bp.route('/agencies/<agency_id>/reviews', methods=['GET'])
@token_required
def list_reviews(current_user_id, agency_id):
    agency, err, code = _agency_or_404(agency_id)
    if err:
        return err, code

    reviews = get_reviews_by_agency(agency_id)
    summary = get_agency_rating_summary(agency_id)
    # review row: (id, rating, comment, created_at, reviewer)
    # summary: (total, average)
    return jsonify({
        "summary": {
            "total_reviews": summary[0],
            "average_rating": float(summary[1]) if summary[1] else None
        },
        "reviews": [
            {"id": str(r[0]), "rating": r[1], "comment": r[2], "created_at": r[3].isoformat(), "reviewer": r[4]}
            for r in reviews
        ]
    }), 200
