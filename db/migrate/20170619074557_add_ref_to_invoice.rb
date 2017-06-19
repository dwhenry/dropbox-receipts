class AddRefToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :reference, :string
  end
end
