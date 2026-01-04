-- Create admin_identities table in identity schema
-- Purpose: Admin authentication with username/password
-- Bounded Context: Identity

CREATE TABLE identity.admin_identities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(100) NOT NULL,
  encrypted_password VARCHAR(255) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  failed_attempts INTEGER NOT NULL DEFAULT 0,
  locked_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Unique index on username (case-insensitive)
CREATE UNIQUE INDEX idx_admin_identities_username
  ON identity.admin_identities(LOWER(username));

-- Check constraint for status values
ALTER TABLE identity.admin_identities
  ADD CONSTRAINT chk_admin_identities_status
  CHECK (status IN ('active', 'locked'));

-- Add updated_at trigger (reuses function from shopper_identities)
CREATE TRIGGER update_admin_identities_updated_at
  BEFORE UPDATE ON identity.admin_identities
  FOR EACH ROW EXECUTE FUNCTION identity.update_updated_at_column();

-- Comment
COMMENT ON TABLE identity.admin_identities IS
  'Admin authentication records. Created via rake task only (no web registration).';
