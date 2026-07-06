from flask import Blueprint, request, jsonify
from app.repositories.agency_repository import (
    create_agency, get_agency_by_owner, get_agency_by_id, get_agency_members
)
from app.repositories.user_repository import get_user_by_id
from app.utils.auth_utils import roles_required

agency_bp = Blueprint('agency', __name__)


@agency_bp.route('/agencies', methods=['POST'])
@roles_required('super_admin')
def create_agency_route(current_user_id):
    data = request.json or {}
    if not data.get('name'):
        return jsonify({"error": "Missing fields: name"}), 400

    agency = create_agency(data['name'], current_user_id)
    return jsonify({
        "id": str(agency[0]),
        "name": agency[1],
        "owner_id": str(agency[2]),
        "created_at": agency[3].isoformat()
    }), 201



@agency_bp.route('/agencies/<agency_id>/members', methods=['GET'])
@roles_required('super_admin', 'agency_admin')
def list_members(current_user_id, agency_id):
    agency = get_agency_by_id(agency_id)
    if not agency:
        return jsonify({"error": "Agency not found."}), 404

    # col indices: 0=id, 1=name, 2=email, 3=phone_number, 4=role, 5=agency_id
    user = get_user_by_id(current_user_id)
    if user[4] != 'super_admin' and str(user[5]) != agency_id:
        return jsonify({"error": "Forbidden: You cannot access other agencies."}), 403

    members = get_agency_members(agency_id)
    return jsonify([
        {"id": str(m[0]), "name": m[1], "email": m[2], "phone": m[3], "role": m[4], "agency_role": m[5]}
        for m in members
    ]), 200



