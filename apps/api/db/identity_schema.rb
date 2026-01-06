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

ActiveRecord::Schema[8.1].define(version: 0) do
  create_schema "identity"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_net"
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "shopper_identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", limit: 255, null: false
    t.boolean "email_verified", default: false, null: false
    t.string "encrypted_password", limit: 255, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at", precision: nil
    t.string "name", limit: 100, null: false
    t.string "provider", limit: 50
    t.string "status", limit: 20, default: "active", null: false
    t.string "uid", limit: 255
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index "lower((email)::text)", name: "idx_shopper_identities_email", unique: true
    t.index ["provider", "uid"], name: "idx_shopper_identities_provider_uid", unique: true, where: "(provider IS NOT NULL)"
  end
end
