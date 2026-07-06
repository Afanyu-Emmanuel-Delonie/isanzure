CREATE EXTENSION IF NOT EXISTS "uuid-ossp"

CREATE TABLE public.users(
    id UUID PRIMARY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME 
)