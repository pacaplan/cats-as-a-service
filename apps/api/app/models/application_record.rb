class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  # Connect to the primary database (public schema)
  connects_to database: { writing: :primary, reading: :primary }
end
