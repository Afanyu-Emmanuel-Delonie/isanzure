from app.repositories.user_repository import get_db_connection


def create_route(origin, destination, price):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO routes (origin, destination, price)
                VALUES (%s, %s, %s)
                RETURNING id, origin, destination, price;
                """,
                (origin, destination, price)
            )
            conn.commit()
            return cur.fetchone()


def get_all_routes():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, origin, destination, price FROM routes ORDER BY origin;")
            return cur.fetchall()


def get_route_by_id(route_id):
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, origin, destination, price FROM routes WHERE id = %s;",
                (route_id,)
            )
            return cur.fetchone()
