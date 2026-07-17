import jwt
from flask import request, jsonify
from functools import wraps
from config import settings

VALID_ROLES = {'super_admin', 'rental_company', 'agency_admin', 'passenger'}


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
