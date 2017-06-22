class AddRecipientsToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :recipients, :text
    add_column :invoices, :notes, :text
  end
end
