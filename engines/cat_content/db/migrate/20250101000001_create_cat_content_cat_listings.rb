class CreateCatContentCatListings < ActiveRecord::Migration[7.1]
  def change
    # Set search_path to use the cat_content schema
    execute "SET search_path TO cat_content"

    create_table :cat_listings, id: :uuid do |t|
      t.string :name, limit: 100, null: false
      t.string :slug, limit: 100, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.string :currency, limit: 3, default: "USD"
      t.string :visibility, limit: 20, null: false, default: "private"
      t.text :image_url
      t.text :image_alt
      t.string :tags, array: true, default: []
      t.integer :age_months
      t.text :temperament
      t.string :traits, array: true, default: []

      t.timestamps
    end

    add_index :cat_listings, :slug, unique: true
    add_index :cat_listings, :visibility
    add_index :cat_listings, :tags, using: :gin

    # Reset search_path
    execute "RESET search_path"
  end
end
