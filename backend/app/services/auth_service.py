import secrets
from datetime import datetime, timedelta
from app.utils.auth_utils import hash_password, check_password, generate_jwt, VALID_ROLES
from app.repositories.user_repository import (
    create_user, get_user_by_email,
    save_otp, get_latest_otp, delete_otp
)

class AuthService:

    @staticmethod
    def initiate_signup(email, password, name, phone, role):
        if role not in VALID_ROLES:
            raise ValueError(f"Invalid role. Must be one of: {', '.join(VALID_ROLES)}")
        if get_user_by_email(email):
            raise ValueError("An account with this email already exists.")

        otp = str(secrets.randbelow(1000000)).zfill(6)
        otp_hash = hash_password(otp)
        from datetime import timezone
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)

        save_otp(email, otp_hash, expires_at)
        return otp

    @staticmethod
    def verify_signup_otp(email, provided_otp, name, password, phone, role):
        stored_otp_data = get_latest_otp(email)
        if not stored_otp_data:
            raise ValueError("No OTP found for this email.")

        stored_hash, expires_at = stored_otp_data

        from datetime import timezone
        if datetime.now(timezone.utc) > expires_at:
            delete_otp(email)
            raise ValueError("OTP has expired.")

        if not check_password(provided_otp, stored_hash):
            raise ValueError("Invalid OTP code.")

        password_hash = hash_password(password)
        user_id = create_user(name, email, phone, password_hash, role)

        delete_otp(email)
        return generate_jwt(user_id, role)

    @staticmethod
    def login(email, password):
        user = get_user_by_email(email)
        if not user:
            raise ValueError("Invalid email or password.")

        user_id, name, email, stored_hash, role = user

        if not check_password(password, stored_hash):
            raise ValueError("Invalid email or password.")

        return generate_jwt(user_id, role)