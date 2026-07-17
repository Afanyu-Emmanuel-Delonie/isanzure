from flask import Blueprint
from app.routes.v1.auth_routes import auth_bp
from app.routes.v1.agency_routes import agency_bp
from app.routes.v1.transit_routes import transit_bp
from app.routes.v1.booking_routes import booking_bp

v1_bp = Blueprint('v1', __name__, url_prefix='/api/v1')
v1_bp.register_blueprint(auth_bp, url_prefix='/auth')
v1_bp.register_blueprint(agency_bp, url_prefix='/agencies')
v1_bp.register_blueprint(transit_bp, url_prefix='/transits')
v1_bp.register_blueprint(booking_bp, url_prefix='/bookings')
