-- Migration: 002_add_role_to_users

CREATE TYPE user_role AS ENUM ('super_admin', 'rental_company', 'agency', 'customer');

ALTER TABLE users ADD COLUMN role user_role NOT NULL DEFAULT 'customer';
