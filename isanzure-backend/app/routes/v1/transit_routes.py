from flask import Blueprint

transit_bp = Blueprint("transit", __name__, url_prefix="/transit")


@transit_bp.route("/", methods=["GET"])
def get_transit():
    pass
