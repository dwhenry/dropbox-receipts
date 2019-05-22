# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190521152102) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_lines", force: :cascade do |t|
    t.string   "name"
    t.string   "account_num"
    t.string   "sort_code"
    t.integer  "previous_id"
    t.integer  "company_id"
    t.decimal  "amount",           precision: 8, scale: 2
    t.decimal  "balance",          precision: 8, scale: 2
    t.date     "transaction_date"
    t.string   "description"
    t.string   "transaction_type"
    t.integer  "source_id"
    t.string   "source_type"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["account_num"], name: "index_bank_lines_on_account_num", using: :btree
    t.index ["company_id"], name: "index_bank_lines_on_company_id", using: :btree
    t.index ["name"], name: "index_bank_lines_on_name", using: :btree
    t.index ["previous_id"], name: "index_bank_lines_on_previous_id", using: :btree
    t.index ["sort_code"], name: "index_bank_lines_on_sort_code", using: :btree
    t.index ["source_id"], name: "index_bank_lines_on_source_id", using: :btree
    t.index ["source_type"], name: "index_bank_lines_on_source_type", using: :btree
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "query_id"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id", using: :btree
    t.index ["user_id"], name: "index_blazer_audits_on_user_id", using: :btree
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "query_id"
    t.string   "state"
    t.string   "schedule"
    t.text     "emails"
    t.text     "slack_channels"
    t.string   "check_type"
    t.text     "message"
    t.datetime "last_run_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id", using: :btree
    t.index ["query_id"], name: "index_blazer_checks_on_query_id", using: :btree
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.integer  "dashboard_id"
    t.integer  "query_id"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id", using: :btree
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id", using: :btree
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.integer  "creator_id"
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id", using: :btree
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "primary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_companies_on_user_id", using: :btree
  end

  create_table "dividends", force: :cascade do |t|
    t.integer  "company_id"
    t.date     "dividend_date"
    t.decimal  "total_amount",  precision: 8, scale: 2
    t.jsonb    "data_rows"
    t.datetime "generated_at"
    t.datetime "sent_at"
    t.text     "recipients"
    t.string   "company_name"
    t.string   "company_reg"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["company_id"], name: "index_dividends_on_company_id", using: :btree
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "company_id"
    t.text     "to_address"
    t.string   "company_name"
    t.text     "company_address"
    t.string   "company_reg"
    t.string   "company_vat"
    t.string   "number"
    t.date     "tax_date"
    t.string   "po_number"
    t.string   "terms"
    t.date     "due_date"
    t.datetime "generated_at"
    t.boolean  "deleted",         default: false
    t.jsonb    "data_rows"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "reference"
    t.datetime "sent_at"
    t.string   "account_name"
    t.string   "account_number"
    t.string   "account_sort"
    t.text     "recipients"
    t.text     "notes"
    t.index ["company_id"], name: "index_invoices_on_company_id", using: :btree
  end

  create_table "manual_matches", force: :cascade do |t|
    t.integer  "company_id"
    t.date     "date"
    t.string   "payment_type"
    t.decimal  "amount",          precision: 8, scale: 2
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "payment_subtype"
    t.index ["company_id"], name: "index_manual_matches_on_company_id", using: :btree
    t.index ["date"], name: "index_manual_matches_on_date", using: :btree
  end

  create_table "receipts", force: :cascade do |t|
    t.integer  "company_id"
    t.binary   "image"
    t.date     "purchase_date"
    t.string   "code"
    t.decimal  "amount",                    precision: 8, scale: 2
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "path",          limit: 511
    t.string   "company_name"
    t.boolean  "deleted",                                           default: false
    t.string   "payer"
    t.index ["company_id"], name: "index_receipts_on_company_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "token"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "company_name"
    t.boolean  "is_accountant"
  end

  add_foreign_key "bank_lines", "users", column: "company_id"
  add_foreign_key "companies", "users"
  add_foreign_key "dividends", "users", column: "company_id"
  add_foreign_key "invoices", "users", column: "company_id"
  add_foreign_key "receipts", "users", column: "company_id"
end
