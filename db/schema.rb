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

ActiveRecord::Schema[8.0].define(version: 2025_07_09_142102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "cpf_cnpj", null: false
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf_cnpj"], name: "index_customers_on_cpf_cnpj", unique: true
    t.index ["email"], name: "index_customers_on_email"
    t.index ["name"], name: "index_customers_on_name"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_departments_on_active"
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "quote_items", force: :cascade do |t|
    t.bigint "quote_id", null: false
    t.bigint "service_type_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.string "unit_price_currency", default: "BRL", null: false
    t.integer "total_price_cents", default: 0, null: false
    t.string "total_price_currency", default: "BRL", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_id"], name: "index_quote_items_on_quote_id"
    t.index ["service_type_id"], name: "index_quote_items_on_service_type_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.bigint "user_id", null: false
    t.integer "total_amount_cents", default: 0, null: false
    t.string "total_amount_currency", default: "BRL", null: false
    t.string "status", default: "draft", null: false
    t.text "notes"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_quotes_on_expires_at"
    t.index ["status"], name: "index_quotes_on_status"
    t.index ["user_id"], name: "index_quotes_on_user_id"
    t.index ["vehicle_id", "status"], name: "index_quotes_on_vehicle_id_and_status"
    t.index ["vehicle_id"], name: "index_quotes_on_vehicle_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "default_price_cents", default: 0, null: false
    t.string "default_price_currency", default: "BRL", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_service_types_on_active"
    t.index ["name"], name: "index_service_types_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.integer "role", default: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "vehicle_brands", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vehicle_brands_on_name", unique: true
    t.index ["slug"], name: "index_vehicle_brands_on_slug", unique: true
  end

  create_table "vehicle_models", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.bigint "vehicle_brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "initial_year"
    t.integer "final_year"
    t.boolean "active"
    t.index ["name"], name: "index_vehicle_models_on_name"
    t.index ["slug"], name: "index_vehicle_models_on_slug", unique: true
    t.index ["vehicle_brand_id", "name"], name: "index_vehicle_models_on_vehicle_brand_id_and_name", unique: true
    t.index ["vehicle_brand_id"], name: "index_vehicle_models_on_vehicle_brand_id"
  end

  create_table "vehicle_statuses", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.bigint "department_id", null: false
    t.bigint "work_order_id", null: false
    t.bigint "user_id", null: false
    t.string "status", default: "entered", null: false
    t.datetime "entered_at", null: false
    t.datetime "exited_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_vehicle_statuses_on_department_id"
    t.index ["entered_at"], name: "index_vehicle_statuses_on_entered_at"
    t.index ["exited_at"], name: "index_vehicle_statuses_on_exited_at"
    t.index ["status"], name: "index_vehicle_statuses_on_status"
    t.index ["user_id"], name: "index_vehicle_statuses_on_user_id"
    t.index ["vehicle_id", "exited_at"], name: "index_vehicle_statuses_on_vehicle_id_and_exited_at"
    t.index ["vehicle_id"], name: "index_vehicle_statuses_on_vehicle_id"
    t.index ["work_order_id"], name: "index_vehicle_statuses_on_work_order_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "license_plate", null: false
    t.integer "year"
    t.string "color", null: false
    t.bigint "customer_id", null: false
    t.bigint "vehicle_brand_id", null: false
    t.bigint "vehicle_model_id", null: false
    t.string "qr_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_vehicles_on_customer_id"
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
    t.index ["qr_code"], name: "index_vehicles_on_qr_code", unique: true
    t.index ["vehicle_brand_id"], name: "index_vehicles_on_vehicle_brand_id"
    t.index ["vehicle_model_id"], name: "index_vehicles_on_vehicle_model_id"
  end

  create_table "work_order_items", force: :cascade do |t|
    t.bigint "work_order_id", null: false
    t.bigint "service_type_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.string "unit_price_currency", default: "BRL", null: false
    t.integer "total_price_cents", default: 0, null: false
    t.string "total_price_currency", default: "BRL", null: false
    t.text "description"
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_work_order_items_on_completed"
    t.index ["service_type_id"], name: "index_work_order_items_on_service_type_id"
    t.index ["work_order_id"], name: "index_work_order_items_on_work_order_id"
  end

  create_table "work_orders", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.bigint "user_id", null: false
    t.bigint "quote_id"
    t.integer "total_amount_cents", default: 0, null: false
    t.string "total_amount_currency", default: "BRL", null: false
    t.string "status", default: "pending", null: false
    t.string "priority", default: "normal", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_work_orders_on_completed_at"
    t.index ["priority"], name: "index_work_orders_on_priority"
    t.index ["quote_id"], name: "index_work_orders_on_quote_id"
    t.index ["started_at"], name: "index_work_orders_on_started_at"
    t.index ["status"], name: "index_work_orders_on_status"
    t.index ["user_id"], name: "index_work_orders_on_user_id"
    t.index ["vehicle_id", "status"], name: "index_work_orders_on_vehicle_id_and_status"
    t.index ["vehicle_id"], name: "index_work_orders_on_vehicle_id"
  end

  add_foreign_key "quote_items", "quotes"
  add_foreign_key "quote_items", "service_types"
  add_foreign_key "quotes", "users"
  add_foreign_key "quotes", "vehicles"
  add_foreign_key "vehicle_models", "vehicle_brands"
  add_foreign_key "vehicle_statuses", "departments"
  add_foreign_key "vehicle_statuses", "users"
  add_foreign_key "vehicle_statuses", "vehicles"
  add_foreign_key "vehicle_statuses", "work_orders"
  add_foreign_key "vehicles", "customers"
  add_foreign_key "vehicles", "vehicle_brands"
  add_foreign_key "vehicles", "vehicle_models"
  add_foreign_key "work_order_items", "service_types"
  add_foreign_key "work_order_items", "work_orders"
  add_foreign_key "work_orders", "quotes"
  add_foreign_key "work_orders", "users"
  add_foreign_key "work_orders", "vehicles"
end
