from flask import Blueprint, request, jsonify
from app.repositories.agency_repository import (
    create_agency, get_agency_by_owner, get_agency_by_id,
    create_invitation, get_invitation_by_token,
    accept_invitation, get_agency_members, get_pending_invitations
)
from app.repositories.user_repository import get_user_by_email
from app.services.auth_service import generate_reset_token
from app.utils.auth_utils import token_required, roles_required

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


@agency_bp.route('/agencies/<agency_id>/invite', methods=['POST'])
@roles_required('super_admin', 'agency')
def invite_user(current_user_id, agency_id):
    data = request.json or {}
    if not data.get('email'):
        return jsonify({"error": "Missing fields: email"}), 400

    agency = get_agency_by_id(agency_id)
    if not agency:
        return jsonify({"error": "Agency not found."}), 404

    token, expires_at = generate_reset_token()
    invitation = create_invitation(data['email'], agency_id, token, expires_at)

    # TODO: Send invite token via email. Returning token directly for dev only.
    return jsonify({
        "id": str(invitation[0]),
        "email": invitation[1],
        "agency_id": str(invitation[2]),
        "status": invitation[3],
        "expires_at": invitation[4].isoformat(),
        "invite_token": token
    }), 201


@agency_bp.route('/agencies/accept-invite', methods=['POST'])
@token_required
def accept_invite(current_user_id):
    data = request.json or {}
    if not data.get('invite_token'):
        return jsonify({"error": "Missing fields: invite_token"}), 400

    invitation = get_invitation_by_token(data['invite_token'])
    if not invitation:
        return jsonify({"error": "Invalid or expired invitation token."}), 400

    agency_id = accept_invitation(data['invite_token'], current_user_id)
    if not agency_id:
        return jsonify({"error": "Failed to accept invitation."}), 400

    return jsonify({
        "message": "Invitation accepted. You are now a member of the agency.",
        "agency_id": str(agency_id)
    }), 200


@agency_bp.route('/agencies/<agency_id>/members', methods=['GET'])
@roles_required('super_admin', 'agency')
def list_members(current_user_id, agency_id):
    agency = get_agency_by_id(agency_id)
    if not agency:
        return jsonify({"error": "Agency not found."}), 404

    members = get_agency_members(agency_id)
    return jsonify([
        {"id": str(m[0]), "name": m[1], "email": m[2], "phone": m[3], "role": m[4]}
        for m in members
    ]), 200


@agency_bp.route('/agencies/<agency_id>/invitations', methods=['GET'])
@roles_required('super_admin', 'agency')
def list_invitations(current_user_id, agency_id):
    agency = get_agency_by_id(agency_id)
    if not agency:
        return jsonify({"error": "Agency not found."}), 404

    invitations = get_pending_invitations(agency_id)
    return jsonify([
        {
            "id": str(i[0]),
            "email": i[1],
            "status": i[2],
            "expires_at": i[3].isoformat(),
            "created_at": i[4].isoformat()
        }
        for i in invitations
    ]), 200
