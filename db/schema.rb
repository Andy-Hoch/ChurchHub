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

ActiveRecord::Schema[8.1].define(version: 2026_10_06_074300) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.boolean "featured", default: false, null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
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
