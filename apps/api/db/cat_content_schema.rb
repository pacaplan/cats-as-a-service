# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_16_000001) do
  create_schema "cat_content"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_net"
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "cat_listings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "age_months"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.string "currency", limit: 3, default: "USD"
    t.text "description", null: false
    t.text "image_alt"
    t.text "image_url"
    t.string "name", limit: 100, null: false
    t.integer "price_cents", null: false
    t.string "slug", limit: 100, null: false
    t.text "tags", default: [], array: true
    t.text "temperament"
    t.text "traits", default: [], array: true
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.string "visibility", limit: 20, default: "private", null: false
    t.index ["slug"], name: "idx_cat_listings_slug"
    t.index ["tags"], name: "idx_cat_listings_tags", using: :gin
    t.index ["visibility"], name: "idx_cat_listings_visibility"
    t.unique_constraint ["slug"], name: "cat_listings_slug_key"
  end

  create_table "custom_cats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_alt"
    t.string "image_url"
    t.string "name", null: false
    t.text "prompt_text"
    t.text "story_text"
    t.string "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.string "visibility", null: false
    t.index ["user_id"], name: "index_custom_cats_on_user_id"
    t.index ["visibility"], name: "index_custom_cats_on_visibility"
  end
end
