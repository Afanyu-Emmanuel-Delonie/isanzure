from flask import Blueprint, request, jsonify
from app.services.auth_service import hash_password, check_password, generate_jwt
from app.repositories.user_repository import create_user, get_user_by_email

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/api/signup', methods=['POST'])
def signup():
    data = request.json
    hashed = hash_password(data['password'])
    user_id = create_user(data['email'], hashed)
    return jsonify({"user_id": user_id, "message": "User created"}), 201

@auth_bp.route('/api/login', methods=['POST'])
def login():
    data = request.json
    user = get_user_by_email(data['email'])
    
    if user and check_password(data['password'], user[2]):
        token = generate_jwt(user[0])
        return jsonify({"token": token}), 200
    
    return jsonify({"message": "Invalid credentials"}), 401