import psycopg2
from config import settings

def get_db_connection():
    return psycopg2.connect(settings.DATABASE_URL)

def create_user(email)