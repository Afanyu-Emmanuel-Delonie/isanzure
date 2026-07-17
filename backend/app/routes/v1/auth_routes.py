from flask import Blueprint, request, jsonify
from app.services.auth_service import AuthService
from app.repositories.user_repository import (
    get_user_by_email, get_user_by_id,
    get_user_by_reset_token, update_reset_token, update_password, update_profile
)
from app.utils.auth_utils import (
    hash_password, check_password, generate_jwt,
    generate_reset_token, token_required, VALID_ROLES
)
from app.utils.mailer import send_otp_email, send_reset_email

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.json
    try:
        # 1. Generate OTP via Service
        otp = AuthService.initiate_signup(
            data['email'], data['password'], data['name'], data['phone'], data['role']
        )
        
        # 2. Send the styled email
        send_otp_email(data['email'], otp, data['name'])
        
        return jsonify({"message": "Verification code sent to your email"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@auth_bp.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.json
    required_fields = ('email', 'otp', 'name', 'password', 'phone', 'role')
    
    # Validation
    if missing := [f for f in required_fields if not data.get(f)]:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    try:
        token = AuthService.verify_signup_otp(
            email=data['email'],
            provided_otp=data['otp'],
            name=data['name'],
            password=data['password'],
            phone=data['phone'],
            role=data['role']
        )
        
        return jsonify({"token": token, "message": "Account created successfully"}), 201
        
    except ValueError as e:
        # This catches "Invalid OTP" or "Expired OTP" errors
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": "An unexpected error occurred"}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json or {}
    if missing := [f for f in ('email', 'password') if not data.get(f)]:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    user = get_user_by_email(data['email'])
    if not user:
        return jsonify({"error": "No account found with this email"}), 401

    if not check_password(data['password'], user[3]):
        return jsonify({"error": "Incorrect password"}), 401

    # user: (id, name, email, password_hash, role)
    token = generate_jwt(user[0], user[4])
    return jsonify({"token": token, "role": user[4]}), 200


@auth_bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.json or {}
    if not data.get('email'):
        return jsonify({"error": "Missing fields: email"}), 400

    user = get_user_by_email(data['email'])
    if not user:
        return jsonify({"error": "No account found with that email."}), 404

    token, expires_at = generate_reset_token()
    update_reset_token(data['email'], token, expires_at)

    try:
        send_reset_email(data['email'], token, user[1])
    except Exception as e:
        return jsonify({"error": f"Could not send reset email: {str(e)}"}), 500

    return jsonify({"message": "If that email exists, a reset link has been sent."}), 200


@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    data = request.json or {}
    missing = [f for f in ('reset_token', 'new_password') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    user = get_user_by_reset_token(data['reset_token'])
    if not user:
        return jsonify({"error": "Invalid or expired reset token."}), 400

    hashed = hash_password(data['new_password'])
    update_password(user[0], hashed)
    return jsonify({"message": "Password reset successful."}), 200


@auth_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user_id):
    user = get_user_by_id(current_user_id)
    if not user:
        return jsonify({"error": "User not found."}), 404

    # user: (id, name, email, phone_number, role, agency_id, created_at)
    return jsonify({
        "id": str(user[0]),
        "name": user[1],
        "email": user[2],
        "phone": user[3],
        "role": user[4],
        "agency_id": str(user[5]) if user[5] else None,
        "created_at": user[6].isoformat()
    }), 200


@auth_bp.route('/profile', methods=['PUT'])
@token_required
def update_profile_route(current_user_id):
    data = request.json or {}
    missing = [f for f in ('name', 'phone') if not data.get(f)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400

    user = update_profile(current_user_id, data['name'], data['phone'])
    # user: (id, name, email, phone, role)
    return jsonify({
        "id": str(user[0]),
        "name": user[1],
        "email": user[2],
        "phone": user[3],
        "role": user[4]
    }), 200
