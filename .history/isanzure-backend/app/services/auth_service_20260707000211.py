import jwt
import datetime
import bcrypt
from config import settings

def hash_password(password: str) ->:
    
    