-- 1. Update Schedules to support Atomic Locking
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS available_seats INTEGER DEFAULT 0;
ALTER TABLE schedules ADD CONSTRAINT check_seats_positive CHECK (available_seats >= 0);

-- Sync available_seats with bus capacities
UPDATE schedules
SET available_seats = buses.capacity
FROM buses
WHERE schedules.bus_id = buses.id;

-- 2. Update Bookings to support Lifecycle Management
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending';
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_reference TEXT;

-- 3. Update Invitations to support Role-Based Access
ALTER TABLE invitations ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'agency_admin';
