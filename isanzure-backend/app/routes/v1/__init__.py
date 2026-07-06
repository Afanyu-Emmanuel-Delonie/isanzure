from flask import Blueprint
from app.routes.v1.auth_routes import auth_bp
from app.routes.v1.agency_routes import agency_bp

v1_bp = Blueprint('v1', __name__, url_prefix='/api/v1')
v1_bp.register_blueprint(auth_bp)
v1_bp.register_blueprint(agency_bp)
