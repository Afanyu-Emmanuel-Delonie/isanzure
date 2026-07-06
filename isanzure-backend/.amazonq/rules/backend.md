# Isanzure Backend — Engineering Rules

## Stack
- Python 3.13, Flask 3.x, PostgreSQL, psycopg2-binary
- JWT (PyJWT) for stateless auth, Bcrypt for password hashing
- pydantic-settings for environment config
- Gevent + Gunicorn for production concurrency
- Swagger UI at /api/docs via flask-swagger-ui

---

## Architecture

### Layer Responsibilities
- `routes/`       → HTTP only. Parse request, call service or repository, return JSON. No SQL, no business logic.
- `services/`     → Pure business logic. No Flask imports, no direct SQL.
- `repositories/` → All SQL lives here. No business logic. Always use parameterized queries.
- `utils/`        → Shared decorators and helpers (token_required, roles_required).
- `migrations/`   → Versioned SQL files. Never modify an already-applied migration.

### Never
- Never put SQL in routes or services
- Never put business logic in repositories
- Never import Flask's `request` or `jsonify` outside of routes
- Never hardcode credentials, secrets, or environment values
- Never use string formatting for SQL — always use psycopg2 parameterization (%s)

---

## Database

### Migrations
- All schema changes go through `migrations/` as versioned SQL files
- Naming convention: `NNN_description.sql` (e.g. `003_create_buses_table.sql`)
- Run with `python migrate.py` — never apply SQL manually to production
- Never modify an existing migration file — create a new one instead
- Every new table must have: `id UUID PRIMARY KEY DEFAULT uuid_generate_v4()`, `created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP`

### Queries
- Always use parameterized queries: `cur.execute("SELECT ... WHERE id = %s", (id,))`
- Use `RETURNING` clause on INSERT to get the created record back
- Use `FOR UPDATE` row locking for any booking or seat reservation logic
- Always close cursors and connections — use context managers (`with`)

---

## API Design

### Versioning
- All endpoints are versioned under `/api/vN/` (e.g. `/api/v1/signup`)
- Each version has its own Blueprint folder: `app/routes/v1/`, `app/routes/v2/`
- Each version folder has an `__init__.py` that registers all its route blueprints under a parent `vN_bp` with `url_prefix='/api/vN'`
- Route files inside a version folder use relative paths only (e.g. `/signup`, not `/api/v1/signup`)
- Register new versions in `app/__init__.py` alongside existing ones — never remove old versions without a deprecation period
- Swagger docs must reflect the correct versioned paths

### Conventions
- All endpoints are prefixed `/api/`
- Use plural nouns for resources: `/api/buses`, `/api/bookings`
- HTTP methods: GET=read, POST=create, PUT=full update, PATCH=partial update, DELETE=remove
- Always return JSON — never plain text or HTML
- Use consistent response shapes:
  - Success: return the resource or `{"message": "..."}` with appropriate 2xx status
  - Error: always `{"error": "..."}` with appropriate 4xx/5xx status

### Status Codes
- 200 OK — successful GET, PUT, PATCH
- 201 Created — successful POST that creates a resource
- 400 Bad Request — missing or invalid input
- 401 Unauthorized — missing or invalid token
- 403 Forbidden — valid token but insufficient role
- 404 Not Found — resource does not exist
- 409 Conflict — duplicate resource (e.g. email already exists)
- 500 Internal Server Error — unhandled server error

### Input Validation
- Always validate required fields at the route level before calling any service or repository
- Return 400 with a list of missing fields: `{"error": "Missing fields: name, email"}`
- Never let a KeyError or missing field crash the server

---

## Authentication & Authorization

### JWT
- Tokens expire in 24 hours
- JWT payload must include: `sub` (user_id), `role`, `iat`, `exp`
- Always decode with `algorithms=[settings.JWT_ALGORITHM]`
- Never trust the role from the request body for authorization — always read from the token

### Decorators
- `@token_required` — injects `current_user_id` as first argument
- `@roles_required('role1', 'role2')` — injects `current_user_id`, returns 403 if role not allowed
- Apply auth decorators before any business logic

### Roles
- `super_admin` — full platform access
- `rental_company` — manages their own vehicles and rentals
- `agency` — manages buses, routes, schedules
- `customer` — books trips, views own bookings

### Passwords
- Always hash with bcrypt before storing
- Never log, return, or expose password_hash in any response
- Reset tokens expire in 30 minutes and are cleared after use

---

## Code Style

### General
- Follow PEP 8
- No unused imports
- No commented-out dead code
- Functions do one thing — keep them short and focused
- Prefer explicit over implicit

### Naming
- snake_case for all Python identifiers
- UPPER_SNAKE_CASE for constants and env config fields
- SQL table and column names in snake_case
- Migration files: `NNN_verb_noun.sql`

### Error Handling
- Never use bare `except:` — always catch specific exceptions
- Log errors server-side, return generic messages to the client
- Never expose stack traces or internal details in API responses

---

## Documentation

### Swagger
- Every new endpoint must be documented in `app/static/swagger.json`
- Document all request body fields, required fields, and response examples
- Protected endpoints must include `"security": [{ "BearerAuth": [] }]`
- Keep the `UserRole` enum schema in components in sync with `VALID_ROLES` in `auth_utils.py`

### README
- Keep the endpoint table in `README.md` up to date when adding new routes
- Document any new environment variables in the `.env` section

---

## Security

- Never commit `.env` to version control
- Always add `.env` to `.gitignore`
- Sanitize all user input before use
- Use `secrets.token_urlsafe()` for reset tokens and any random token generation
- CORS is restricted to `/api/*` — do not open it globally
- Never return sensitive fields (`password_hash`, `reset_token`) in any API response
