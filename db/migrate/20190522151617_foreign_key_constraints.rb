class ForeignKeyConstraints < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key "bank_lines", "users"
    remove_foreign_key "dividends", "users"
    remove_foreign_key "invoices", "users"
    remove_foreign_key "receipts", "users"

    add_foreign_key "bank_lines", "companies", column: "company_id"
    add_foreign_key "dividends", "companies", column: "company_id"
    add_foreign_key "invoices", "companies", column: "company_id"
    add_foreign_key "receipts", "companies", column: "company_id"
  end
end
