-- Create the cat_content schema for the Cat & Content bounded context
CREATE SCHEMA IF NOT EXISTS cat_content;

-- Grant permissions to postgres user (local development)
GRANT USAGE ON SCHEMA cat_content TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cat_content TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA cat_content TO postgres;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA cat_content TO postgres;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA cat_content 
  GRANT ALL ON TABLES TO postgres;
  
ALTER DEFAULT PRIVILEGES IN SCHEMA cat_content 
  GRANT ALL ON SEQUENCES TO postgres;
  
ALTER DEFAULT PRIVILEGES IN SCHEMA cat_content 
  GRANT ALL ON FUNCTIONS TO postgres;

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Comment explaining the schema isolation approach
COMMENT ON SCHEMA cat_content IS 'Cat & Content bounded context - isolated schema for catalog and custom cat management';


