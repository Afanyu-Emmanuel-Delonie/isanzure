-- Migration: 005_agency_roles_and_reviews

-- Agency-level role for members within an agency
-- Values: 'manager', 'branch', 'customer_support', 'driver'
ALTER TABLE users ADD COLUMN IF NOT EXISTS agency_role TEXT;

-- Reviews table: passengers review agencies after a trip
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, booking_id)
);
