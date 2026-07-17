import jwt
import datetime
import secrets
import bcrypt
from functools import wraps
from flask import request, jsonify
from config import settings

# --- Constants ---
VALID_ROLES = {'super_admin', 'rental_company', 'agency_admin', 'passenger'}

# --- Password & JWT Helpers ---
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def check_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def generate_jwt(user_id, role: str) -> str:
    payload = {
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24),
        'iat': datetime.datetime.utcnow(),
        'sub': str(user_id),
        'role': role
    }
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

def generate_reset_token() -> tuple[str, datetime.datetime]:
    token = secrets.token_urlsafe(32)
    expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=30)
    return token, expires_at

# --- Decorators ---
def _decode_token():
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return None, ('Token is missing', 401)
    try:
        token = auth_header.split(" ")[1]
        return jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM]), None
    except Exception:
        return None, ('Token is invalid', 401)

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        data, err = _decode_token()
        if err:
            return jsonify({'error': err[0]}), err[1]
        return f(data['sub'], *args, **kwargs)
    return decorated

def roles_required(*roles):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            data, err = _decode_token()
            if err:
                return jsonify({'error': err[0]}), err[1]
            if data.get('role') not in roles:
                return jsonify({'error': 'Access forbidden: insufficient role'}), 403
            return f(data['sub'], *args, **kwargs)
        return decorated
    return decorator