import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    """ Validate and hold application configurations. """
    FLASK_ENV: str = "development"
    DATABASE_URL: str
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    
    class Config:
        # pydantic will check enviroment variables case-insensitively
        case_sensitive = True
        
class Settings:
    MAIL_SERVER = 'smtp.gmail.com' # Or your provider (SendGrid, AWS SES)
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USERNAME = os.getenv('MAIL_USERNAME')
    MAIL_PASSWORD = os.getenv('MAIL_PASSWORD') # Use App Passwords for Gmail
    MAIL_DEFAULT_SENDER = 'noreply@isan.com'
    
settings = Settings()
