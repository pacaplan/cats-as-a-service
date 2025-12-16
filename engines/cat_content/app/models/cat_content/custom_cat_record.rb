# frozen_string_literal: true

module CatContent
  class CustomCatRecord < BaseRecord
    self.table_name = "cat_content.custom_cats"

    validates :name, presence: true
    validates :user_id, presence: true
    validates :visibility, presence: true, inclusion: { in: %w[public private archived] }
  end
end
