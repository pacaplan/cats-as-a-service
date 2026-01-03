# frozen_string_literal: true

module CatContent
  # ActiveRecord model for cat_listings table
  class CatListingRecord < CatContent::BaseRecord
    self.table_name = "cat_content.cat_listings"

    # Scopes
    scope :published, -> { where(visibility: "published") }

    # Validations
    validates :name, presence: true, length: {maximum: 100}
    validates :slug, presence: true, uniqueness: true, length: {maximum: 100}
    validates :description, presence: true
    validates :price_cents, presence: true, numericality: {greater_than_or_equal_to: 0}
    validates :visibility, presence: true, inclusion: {in: %w[private published archived]}
  end
end
