import psycopg2
from config import settings

def get_db_connection():
    return 