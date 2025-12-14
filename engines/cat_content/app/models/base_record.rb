class BaseRecord < ActiveRecord::Base
  self.abstract_class = true

  # Schema isolation is handled by database.yml schema_search_path
  # In production multi-DB setups, configure connects_to at the host app level
end

