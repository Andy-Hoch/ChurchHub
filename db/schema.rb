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

ActiveRecord::Schema[8.1].define(version: 2026_10_01_100000) do
  create_table "churches", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["slug"], name: "index_churches_on_slug", unique: true
  end

  create_table "form_questions", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "kind", default: "short_text", null: false
    t.string "label", null: false
    t.string "help_text"
    t.boolean "required", default: false, null: false
    t.json "choices", default: [], null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "position"], name: "index_form_questions_on_form_id_and_position"
    t.index ["form_id"], name: "index_form_questions_on_form_id"
  end

  create_table "form_submissions", force: :cascade do |t|
    t.integer "form_id", null: false
    t.json "answers", default: [], null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "created_at"], name: "index_form_submissions_on_form_id_and_created_at"
  end

  create_table "forms", force: :cascade do |t|
    t.integer "church_id", null: false
    t.string "title", null: false
    t.text "intro"
    t.text "thank_you_message"
    t.string "submit_label"
    t.string "notification_emails"
    t.text "consent_text"
    t.string "privacy_url"
    t.integer "retention_months"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_id"], name: "index_forms_on_church_id"
  end

  create_table "hubs", force: :cascade do |t|
    t.integer "church_id", null: false
    t.string "title", null: false
    t.string "public_token", null: false
    t.boolean "enabled", default: true, null: false
    t.string "primary_color", default: "oklch(21.03% 0.0059 285.89)", null: false
    t.string "text_color", default: "oklch(100% 0 0)", null: false
    t.string "position", default: "right", null: false
    t.string "button_label", default: "Links", null: false
    t.string "button_icon", default: "grid", null: false
    t.string "color_scheme", default: "light", null: false
    t.integer "corner_radius", default: 12, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "font_family", default: "sans", null: false
    t.index ["church_id"], name: "index_hubs_on_church_id", unique: true
    t.index ["public_token"], name: "index_hubs_on_public_token", unique: true
  end

  create_table "links", force: :cascade do |t|
    t.integer "hub_id", null: false
    t.string "title", null: false
    t.string "url"
    t.string "description"
    t.string "icon"
    t.integer "position", default: 0, null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind", default: "link", null: false
    t.integer "form_id"
    t.index ["form_id"], name: "index_links_on_form_id"
    t.index ["hub_id", "position"], name: "index_links_on_hub_id_and_position"
    t.index ["hub_id"], name: "index_links_on_hub_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "church_id", null: false
    t.string "role", default: "admin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_id"], name: "index_memberships_on_church_id"
    t.index ["user_id", "church_id"], name: "index_memberships_on_user_id_and_church_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "form_questions", "forms"
  add_foreign_key "form_submissions", "forms"
  add_foreign_key "forms", "churches"
  add_foreign_key "hubs", "churches"
  add_foreign_key "links", "forms", on_delete: :nullify
  add_foreign_key "links", "hubs"
  add_foreign_key "memberships", "churches"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
