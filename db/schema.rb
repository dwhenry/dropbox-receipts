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

ActiveRecord::Schema.define(version: 20180707204235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dividends", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "dividend_date"
    t.decimal  "total_amount",  precision: 8, scale: 2
    t.jsonb    "data_rows"
    t.datetime "generated_at"
    t.text     "recipients"
    t.string   "company_name"
    t.string   "company_reg"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["user_id"], name: "index_dividends_on_user_id", using: :btree
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "user_id"
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
    t.index ["user_id"], name: "index_invoices_on_user_id", using: :btree
  end

  create_table "receipts", force: :cascade do |t|
    t.integer  "user_id"
    t.binary   "image"
    t.date     "purchase_date"
    t.string   "code"
    t.decimal  "amount",                    precision: 8, scale: 2
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "path",          limit: 511
    t.string   "company"
    t.boolean  "deleted",                                           default: false
    t.string   "payer"
    t.index ["user_id"], name: "index_receipts_on_user_id", using: :btree
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

  add_foreign_key "dividends", "users"
  add_foreign_key "invoices", "users"
  add_foreign_key "receipts", "users"
end
