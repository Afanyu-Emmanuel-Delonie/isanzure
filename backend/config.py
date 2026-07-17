from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    """ Validate and hold application configurations. """
    FLASK_ENV: str = "development"
    DATABASE_URL: str
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    MAIL_SERVER: str = 'smtp.gmail.com'
    MAIL_PORT: int = 587
    MAIL_USE_TLS: bool = True
    MAIL_USERNAME: str = ''
    MAIL_PASSWORD: str = ''
    MAIL_DEFAULT_SENDER: str = 'noreply@isanzure.com'

    class Config:
        case_sensitive = True

settings = Settings()
