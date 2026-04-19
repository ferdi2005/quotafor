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

ActiveRecord::Schema[8.1].define(version: 2026_04_19_123000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.integer "appointment_type", default: 0, null: false
    t.text "assistance_goal"
    t.boolean "awaiting_bank_transfer", default: false, null: false
    t.decimal "awaiting_bank_transfer_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "deadlines"
    t.datetime "ends_at"
    t.text "invested_resources"
    t.text "negative_reason"
    t.datetime "next_appointment_at"
    t.boolean "next_appointment_callback", default: false, null: false
    t.boolean "ok_current_account", default: false, null: false
    t.integer "outcome"
    t.text "presentation_notes"
    t.text "proposed_changes"
    t.text "referrals"
    t.string "reminder_token"
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false
    t.text "technical_analysis"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.text "visit_feedback"
    t.index ["customer_id", "starts_at"], name: "index_appointments_on_customer_id_and_starts_at"
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["user_id", "starts_at"], name: "index_appointments_on_user_id_and_starts_at"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "banks", force: :cascade do |t|
    t.decimal "amount"
    t.string "bank_name"
    t.decimal "current_account_balance"
    t.bigint "customer_id", null: false
    t.text "deadlines"
    t.text "reason"
    t.string "referente"
    t.decimal "rendimento"
    t.integer "satisfaction_level"
    t.text "use"
    t.text "what_has"
    t.index ["customer_id"], name: "index_banks_on_customer_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.text "description"
    t.datetime "ends_at"
    t.bigint "source_id"
    t.string "source_type"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["customer_id"], name: "index_calendar_events_on_customer_id"
    t.index ["source_type", "source_id"], name: "index_calendar_events_on_source_type_and_source_id"
    t.index ["user_id", "starts_at"], name: "index_calendar_events_on_user_id_and_starts_at"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "children", force: :cascade do |t|
    t.integer "age"
    t.decimal "annual_income"
    t.date "birth_date"
    t.bigint "customer_id", null: false
    t.text "desires"
    t.string "first_name"
    t.string "last_name"
    t.text "profession"
    t.text "solutions"
    t.index ["customer_id"], name: "index_children_on_customer_id"
  end

  create_table "contact_calls", force: :cascade do |t|
    t.integer "call_type", default: 0, null: false
    t.datetime "called_at", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "generated_from_id"
    t.text "notes"
    t.datetime "scheduled_for"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["customer_id"], name: "index_contact_calls_on_customer_id"
    t.index ["generated_from_id"], name: "index_contact_calls_on_generated_from_id", unique: true
    t.index ["user_id"], name: "index_contact_calls_on_user_id"
  end

  create_table "customer_expenses", force: :cascade do |t|
    t.decimal "amount"
    t.integer "category"
    t.bigint "customer_id", null: false
    t.text "description"
    t.string "expense_type"
    t.index ["customer_id"], name: "index_customer_expenses_on_customer_id"
  end

  create_table "customer_objectives", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "description"
    t.decimal "diminished_resources", precision: 12, scale: 2
    t.decimal "invested_resources", precision: 12, scale: 2
    t.text "resources"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_objectives_on_customer_id"
  end

  create_table "customer_titles", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.date "expires_on"
    t.decimal "initial_capital"
    t.string "isin"
    t.decimal "rendimento"
    t.string "title_type"
    t.index ["customer_id"], name: "index_customer_titles_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "annual_income"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.integer "customer_type", default: 0, null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "ok_current_account", default: false, null: false
    t.text "passions"
    t.text "personal_summary"
    t.string "phone"
    t.string "profession"
    t.text "prospects"
    t.bigint "referred_by_customer_id"
    t.date "relationship_started_on", null: false
    t.integer "satisfaction_level"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["profession"], name: "index_customers_on_profession"
    t.index ["referred_by_customer_id"], name: "index_customers_on_referred_by_customer_id"
    t.index ["user_id", "last_name", "first_name"], name: "index_customers_on_user_id_and_last_name_and_first_name"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "in_app_notifications", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "calendar_event_id", null: false
    t.datetime "created_at", null: false
    t.integer "notification_type", default: 0, null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["calendar_event_id"], name: "index_in_app_notifications_on_calendar_event_id"
    t.index ["user_id", "read_at"], name: "index_in_app_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_in_app_notifications_on_user_id"
  end

  create_table "insurances", force: :cascade do |t|
    t.decimal "amount"
    t.string "company_name"
    t.bigint "customer_id", null: false
    t.date "expiry_date"
    t.integer "investment_frequency"
    t.decimal "objective", precision: 12, scale: 2
    t.string "product_name"
    t.string "reason"
    t.decimal "rendimento"
    t.integer "satisfaction_level"
    t.date "subscription_date"
    t.index ["customer_id"], name: "index_insurances_on_customer_id"
  end

  create_table "investments", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "advised_by"
    t.decimal "amount"
    t.bigint "customer_id", null: false
    t.string "distributed_by"
    t.string "product_name"
    t.string "purpose"
    t.integer "satisfaction_level"
    t.date "subscription_date"
    t.boolean "with_me", default: false, null: false
    t.index ["customer_id"], name: "index_investments_on_customer_id"
  end

  create_table "properties", force: :cascade do |t|
    t.text "address"
    t.decimal "annual_income", precision: 12, scale: 2
    t.decimal "annual_maintenance_cost", precision: 12, scale: 2
    t.decimal "commercial_value", precision: 12, scale: 2
    t.bigint "customer_id", null: false
    t.integer "purpose"
    t.index ["customer_id"], name: "index_properties_on_customer_id"
  end

  create_table "recurring_activities", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.date "activity_date"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.time "ends_at", null: false
    t.string "location"
    t.text "notes"
    t.integer "periodicity", default: 1, null: false
    t.time "starts_at", null: false
    t.string "topic", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "weekday", default: 1, null: false
    t.index ["user_id"], name: "index_recurring_activities_on_user_id"
  end

  create_table "spouses", force: :cascade do |t|
    t.integer "age"
    t.decimal "annual_income"
    t.date "birth_date"
    t.bigint "customer_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "profession"
    t.text "prospects"
    t.integer "satisfaction_level"
    t.index ["customer_id"], name: "index_spouses_on_customer_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "calendar_feed_token", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.boolean "email_notifications", default: true, null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "feed_token_generated_at"
    t.string "first_name"
    t.boolean "in_app_notifications", default: true, null: false
    t.string "last_name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.decimal "rfa_expected", precision: 12, scale: 2, default: "0.0", null: false
    t.string "time_zone", default: "Europe/Rome", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_feed_token"], name: "index_users_on_calendar_feed_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "appointments", "customers"
  add_foreign_key "appointments", "users"
  add_foreign_key "banks", "customers"
  add_foreign_key "calendar_events", "customers"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "children", "customers"
  add_foreign_key "contact_calls", "contact_calls", column: "generated_from_id"
  add_foreign_key "contact_calls", "customers"
  add_foreign_key "contact_calls", "users"
  add_foreign_key "customer_expenses", "customers"
  add_foreign_key "customer_objectives", "customers"
  add_foreign_key "customer_titles", "customers"
  add_foreign_key "customers", "customers", column: "referred_by_customer_id"
  add_foreign_key "customers", "users"
  add_foreign_key "in_app_notifications", "calendar_events"
  add_foreign_key "in_app_notifications", "users"
  add_foreign_key "insurances", "customers"
  add_foreign_key "investments", "customers"
  add_foreign_key "properties", "customers"
  add_foreign_key "recurring_activities", "users"
  add_foreign_key "spouses", "customers"
end
