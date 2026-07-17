# app/services/auth_service.py
import secrets
from datetime import datetime, timedelta
from app.utils.auth_utils import hash_password, check_password, generate_jwt 
from app.repository import user_repo, otp_repo

class AuthService:
    
    @staticmethod
    def initiate_signup(email, password, name, phone, role):
        otp = str(secrets.randbelow(1000000)).zfill(6)
        otp_hash = hash_password(otp)
        expires_at = datetime.utcnow() + timedelta(minutes=10)
        
        otp_repo.save_otp(email, otp_hash, expires_at)
        return otp

    @staticmethod
    def verify_signup_otp(email, provided_otp, name, password, phone, role):
        stored_otp_data = otp_repo.get_latest_otp(email)
        if not stored_otp_data:
            raise ValueError("No OTP found for this email.")
            
        stored_hash, expires_at = stored_otp_data
        
        if datetime.utcnow() > expires_at:
            raise ValueError("OTP has expired.")
            
        if not check_password(provided_otp, stored_hash):
            raise ValueError("Invalid OTP code.")
            
        password_hash = hash_password(password)
        user_id = user_repo.create_user(name, email, phone, password_hash, role)
        
        otp_repo.delete_otp(email)
        return generate_jwt(user_id, role)

    @staticmethod
    def login(email, password):
        user = user_repo.get_user_by_email(email)
        if not user:
            raise ValueError("Invalid email or password.")
            
        user_id, _, stored_hash, role = user
        
        if not check_password(password, stored_hash):
            raise ValueError("Invalid email or password.")
            
        return generate_jwt(user_id, role)