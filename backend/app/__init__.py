from flask import Flask
from flask_cors import CORS
from flask_mail import Mail
from flask_swagger_ui import get_swaggerui_blueprint
from config import settings

SWAGGER_URL = '/api/docs'
SWAGGER_JSON_URL = '/static/swagger.json'

mail = Mail()


def create_app():
    """Initializes and configures the Isanzure Flask core platform."""
    app = Flask(__name__, template_folder='../templates')

    app.config['SECRET_KEY'] = settings.JWT_SECRET_KEY
    app.config['ENV'] = settings.FLASK_ENV
    app.config['MAIL_SERVER'] = settings.MAIL_SERVER
    app.config['MAIL_PORT'] = settings.MAIL_PORT
    app.config['MAIL_USE_TLS'] = settings.MAIL_USE_TLS
    app.config['MAIL_USERNAME'] = settings.MAIL_USERNAME
    app.config['MAIL_PASSWORD'] = settings.MAIL_PASSWORD
    app.config['MAIL_DEFAULT_SENDER'] = settings.MAIL_DEFAULT_SENDER

    CORS(app, resources={r"/api/*": {"origins": "*"}})
    mail.init_app(app)

    @app.route('/health', methods=['GET'])
    def health_check():
        return {"status": "healthy", "environment": settings.FLASK_ENV}, 200

    # Swagger UI
    swaggerui_bp = get_swaggerui_blueprint(SWAGGER_URL, SWAGGER_JSON_URL)
    app.register_blueprint(swaggerui_bp)

    # Versioned Routes — imported here to avoid circular imports
    from app.routes.v1 import v1_bp
    app.register_blueprint(v1_bp)

    return app
