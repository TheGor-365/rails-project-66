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

ActiveRecord::Schema[7.2].define(version: 2025_12_07_230803) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "repositories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "github_id"
    t.string "name"
    t.string "full_name"
    t.string "language"
    t.string "clone_url"
    t.string "ssh_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_repositories_on_user_id"
  end

  create_table "repository_checks", force: :cascade do |t|
    t.bigint "repository_id", null: false
    t.string "status", default: "pending", null: false
    t.string "commit_id"
    t.boolean "passed"
    t.integer "violations_count"
    t.text "output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_repository_checks_on_repository_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "nickname"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "image_url"
  end

  add_foreign_key "repositories", "users"
  add_foreign_key "repository_checks", "repositories"
end
