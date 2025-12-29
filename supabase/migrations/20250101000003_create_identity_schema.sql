-- Create identity schema
CREATE SCHEMA IF NOT EXISTS identity;

-- Create shopper_identities table
CREATE TABLE identity.shopper_identities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  encrypted_password VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  provider VARCHAR(50),
  uid VARCHAR(255),
  email_verified BOOLEAN NOT NULL DEFAULT false,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes per spec
CREATE UNIQUE INDEX idx_shopper_identities_email ON identity.shopper_identities(LOWER(email));
CREATE UNIQUE INDEX idx_shopper_identities_provider_uid ON identity.shopper_identities(provider, uid) WHERE provider IS NOT NULL;

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION identity.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_shopper_identities_updated_at BEFORE UPDATE ON identity.shopper_identities
FOR EACH ROW EXECUTE FUNCTION identity.update_updated_at_column();


