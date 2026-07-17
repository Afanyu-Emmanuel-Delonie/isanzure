from flask import Blueprint, request, jsonify
from app.repositories.transit_repository import create_route, get_all_routes, get_route_by_id
from app.utils.auth_utils import token_required, roles_required

transit_bp = Blueprint("transit", __name__)


def _serialize_route(r):
    return {"id": str(r[0]), "origin": r[1], "destination": r[2], "price": float(r[3])}


@transit_bp.route('/routes', methods=['POST'])
@roles_required('super_admin', 'agency_admin')
def create_route_endpoint(current_user_id):
    data = request.json or {}
    missing = [f for f in ('origin', 'destination', 'price') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    try:
        price = float(data['price'])
        if price <= 0:
            raise ValueError
    except (ValueError, TypeError):
        return jsonify({"error": "price must be a positive number."}), 400

    route = create_route(data['origin'], data['destination'], price)
    return jsonify(_serialize_route(route)), 201


@transit_bp.route('/routes', methods=['GET'])
@token_required
def list_routes(current_user_id):
    routes = get_all_routes()
    return jsonify([_serialize_route(r) for r in routes]), 200


@transit_bp.route('/routes/<route_id>', methods=['GET'])
@token_required
def get_route(current_user_id, route_id):
    route = get_route_by_id(route_id)
    if not route:
        return jsonify({"error": "Route not found."}), 404
    return jsonify(_serialize_route(route)), 200
