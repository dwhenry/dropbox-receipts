class AddInvoiceFields < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :sent_at, :datetime
    add_column :invoices, :account_name, :string
    add_column :invoices, :account_number, :string
    add_column :invoices, :account_sort, :string
  end
end
