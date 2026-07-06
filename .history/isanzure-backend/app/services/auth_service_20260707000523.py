import jwt
import datetime
import bcrypt
from config import settings

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def check_password(password: str, hashed: str) -> bool:
    """Verifies a password against the hash."""
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
    
def generate_jwt(user_id: str) -> str:
    payload = {
        
    }