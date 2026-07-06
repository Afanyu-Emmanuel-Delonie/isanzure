from flask import Flask
from flask_cors import CORS
from config import settings
from app


def create_app():
    """Initializes and configures the Isanzure Flask core platform."""
    app = Flask(__name__)

    # 1. Apply global configurations
    app.config['SECRET_KEY'] = settings.JWT_SECRET_KEY
    app.config['ENV'] = settings.FLASK_ENV

    # 2. Enable Cross-Origin Resource Sharing (Allows your mobile frontend to communicate with this API)
    CORS(app, resources={r"/api/*": {"origins": "*"}})


    @app.route('/health', methods=['GET'])
    def health_check():
        return {"status": "healthy", "environment": settings.FLASK_ENV}, 200

    # Registed Routes
    app.register_blueprint(auth_bp)
    return app
