import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    """ Validate and hold application configurations. """
    FLASK_ENV: 
