-- Migration: 004_align_canonical_schema

-- 1. Add contact_email to agencies
ALTER TABLE agencies ADD COLUMN IF NOT EXISTS contact_email TEXT UNIQUE;

-- 2. Rename phone to phone_number on users
ALTER TABLE users RENAME COLUMN phone TO phone_number;

-- 3. Drop the enum role column and replace with plain TEXT to support all role values
ALTER TABLE users DROP COLUMN role;
ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'passenger';

-- 4. Drop token and expires_at from invitations (not in canonical schema)
ALTER TABLE invitations DROP COLUMN IF EXISTS token;
ALTER TABLE invitations DROP COLUMN IF EXISTS expires_at;

-- 5. Drop the now-unused enum type
DROP TYPE IF EXISTS user_role;

-- 6. Buses Table
CREATE TABLE IF NOT EXISTS buses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plate_number TEXT UNIQUE NOT NULL,
    capacity INTEGER NOT NULL,
    status TEXT DEFAULT 'active',
    agency_id UUID REFERENCES agencies(id) ON DELETE CASCADE
);

-- 7. Routes Table
CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    origin TEXT NOT NULL,
    destination TEXT NOT NULL,
    price DECIMAL NOT NULL
);

-- 8. Schedules Table
CREATE TABLE IF NOT EXISTS schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bus_id UUID REFERENCES buses(id) ON DELETE CASCADE,
    route_id UUID REFERENCES routes(id) ON DELETE CASCADE,
    departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Bookings Table
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    schedule_id UUID REFERENCES schedules(id),
    seat_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(schedule_id, seat_number)
);
