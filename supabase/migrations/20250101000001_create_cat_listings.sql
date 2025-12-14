-- Create cat_listings table in cat_content schema
CREATE TABLE IF NOT EXISTS cat_content.cat_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  price_cents INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  visibility VARCHAR(20) NOT NULL DEFAULT 'private',
  image_url TEXT,
  image_alt TEXT,
  tags TEXT[] DEFAULT '{}',
  age_months INTEGER,
  temperament TEXT,
  traits TEXT[] DEFAULT '{}',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on visibility for faster queries
CREATE INDEX IF NOT EXISTS idx_cat_listings_visibility ON cat_content.cat_listings(visibility);

-- Create index on slug for faster lookups
CREATE INDEX IF NOT EXISTS idx_cat_listings_slug ON cat_content.cat_listings(slug);

-- Create index on tags for filtering (GIN index for array operations)
CREATE INDEX IF NOT EXISTS idx_cat_listings_tags ON cat_content.cat_listings USING GIN(tags);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION cat_content.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_cat_listings_updated_at BEFORE UPDATE ON cat_content.cat_listings
FOR EACH ROW EXECUTE FUNCTION cat_content.update_updated_at_column();


