from flask import Flask, jsonify
from flask_cors import CORS
from flask_swagger_ui import get_swaggerui_blueprint
from config import settings
from app.routes.v1 import v1_bp

SWAGGER_URL = '/api/docs'
SWAGGER_JSON_URL = '/static/swagger.json'


def create_app():
    """Initializes and configures the Isanzure Flask core platform."""
    app = Flask(__name__)

    app.config['SECRET_KEY'] = settings.JWT_SECRET_KEY
    app.config['ENV'] = settings.FLASK_ENV

    CORS(app, resources={r"/api/*": {"origins": "*"}})

    @app.route('/health', methods=['GET'])
    def health_check():
        return {"status": "healthy", "environment": settings.FLASK_ENV}, 200

    # Swagger UI
    swaggerui_bp = get_swaggerui_blueprint(SWAGGER_URL, SWAGGER_JSON_URL)
    app.register_blueprint(swaggerui_bp)

    # Versioned Routes
    app.register_blueprint(v1_bp)

    return app
