# Isanzure API

Isanzure is a secure, scalable transit management and booking platform designed for the Rwandan transportation sector. The system connects passengers, transit agencies, and real-time bus tracking.

---

## 🏗️ Project Architecture

The system follows a modular architecture using the **Repository Pattern** to separate business logic from database operations, ensuring maintainability and security.

| Layer | Technology |
|---|---|
| Backend Framework | Flask (Python) |
| Database | PostgreSQL |
| Authentication | JWT with RBAC (Role-Based Access Control) |
| Password Security | Bcrypt hashing |
| SQL Injection Protection | psycopg2 parameterized queries |
| API Documentation | Swagger UI (`/api/docs`) |
| Concurrency | Gevent + Gunicorn |

### Folder Structure

```
isanzure-backend/
├── app/
│   ├── routes/          # Controller layer (Flask Blueprints)
│   ├── services/        # Business logic
│   ├── repositories/    # Database access (SQL)
│   ├── utils/           # Decorators (token_required, roles_required)
│   └── static/          # Swagger JSON spec
├── migrations/          # Versioned SQL migration files
├── migrate.py           # Migration runner
├── config.py            # Environment configuration (pydantic-settings)
├── requirements.txt
└── run.py
```

---

## 📋 Core Modules

### 1. Authentication & Security
Handles user registration, login, and password recovery.

- **Roles:** `customer`, `agency`, `rental_company`, `super_admin`
- **Security:** Stateless JWTs with 24-hour expiration
- **Protected endpoints** require a valid `Authorization: Bearer <token>` header
- Role enforcement via `@roles_required('role_name')` decorator

### 2. Agency Management
Allows registered transport agencies to manage their physical infrastructure.

- **Agencies:** Centralized entity for transit companies
- **Buses:** Each bus is uniquely linked to an `agency_id`

### 3. Transit & Booking Engine
Manages the lifecycle of a trip.

- **Routes & Schedules:** Defines where buses go and when they depart
- **Booking System:** Uses database-level row locking (`FOR UPDATE`) to prevent double-booking of seats

---

## 🚀 Setup & Installation

### Prerequisites

- Python 3.10+
- PostgreSQL
- pip

### Installation

**1. Clone the repository:**
```bash
git clone <your-repo-url>
cd isanzure-backend
```

**2. Set up the virtual environment:**
```bash
python -m venv venv
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate
```

**3. Install dependencies:**
```bash
pip install -r requirements.txt
```

**4. Configure your `.env` file:**
```env
FLASK_ENV=development
DATABASE_URL=postgresql://postgres:<password>@localhost:5432/isanzure_db
JWT_SECRET_KEY=your-secret-key
JWT_ALGORITHM=HS256
```

**5. Run database migrations:**
```bash
python migrate.py
```

**6. Start the server:**
```bash
python run.py
```

The API will be available at `http://localhost:5000`.
Interactive Swagger docs at `http://localhost:5000/api/docs`.

---

## 🔐 API Endpoints

### Auth

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/api/signup` | POST | Public | Register a new user |
| `/api/login` | POST | Public | Login and receive JWT token |
| `/api/forgot-password` | POST | Public | Request a password reset token |
| `/api/reset-password` | POST | Public | Reset password using token |
| `/api/profile` | GET | Bearer | Get current user profile |
| `/api/profile` | PUT | Bearer | Update name and phone |

### Signup Roles

Pass an optional `role` field during signup. Defaults to `customer`.

```json
{
  "name": "John Doe",
  "email": "john@example.rw",
  "phone": "+250788123456",
  "password": "securepassword123",
  "role": "customer"
}
```

Available roles: `customer` · `agency` · `rental_company` · `super_admin`

### Protected Route Usage

```
Authorization: Bearer <jwt_token>
```

---

## 🗄️ Database Migrations

Migrations are versioned SQL files inside the `migrations/` folder and tracked in a `migrations` table.

```bash
# Apply all pending migrations
python migrate.py
```

To add a new migration, create a file following the naming convention:
```
migrations/003_your_migration_name.sql
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| Flask | 3.0.3 | Web framework |
| Flask-Cors | 4.0.1 | Cross-origin requests |
| gevent | 24.11.1 | Async concurrency |
| gunicorn | 22.0.0 | Production WSGI server |
| psycopg2-binary | 2.9.10 | PostgreSQL driver |
| PyJWT | 2.8.0 | JWT authentication |
| bcrypt | 4.1.3 | Password hashing |
| pydantic | 2.11.5 | Data validation |
| pydantic-settings | 2.14.2 | Environment config |
| python-dotenv | 1.0.1 | .env file loading |
| flask-swagger-ui | 5.32.8 | API documentation UI |
