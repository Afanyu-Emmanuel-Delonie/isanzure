from flask import Blueprint

rental_bp = Blueprint("rental", __name__, url_prefix="/rental")


@rental_bp.route("/", methods=["GET"])
def get_rentals():
    pass
