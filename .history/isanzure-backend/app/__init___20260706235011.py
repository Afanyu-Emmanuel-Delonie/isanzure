from flask import Flask
from flask_cors import CORS
from config import Settings


def create_app():
    """Initializes and configures the Isanzure Flask core platform."""
    app = Flask(__name__)

    # 1. Apply global configurations
    app.config['SECRET_KEY'] = Settings.JWT_SECRET_KEY
    app.config['ENV'] = Settings.FLASK_ENV

    # 2. Enable Cross-Origin Resource Sharing (Allows your mobile frontend to communicate with this API)
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    # 3. Simple Health Check Endpoint to verify setup is running
    @app.route('/health', methods=['GET'])
    def health_check():
        return {"status": "healthy", "environment": Settings.FLASK_ENV}, 200

    
    return app
