class AddCompanyToReceipt < ActiveRecord::Migration[5.0]
  def change
    add_column :receipts, :company, :string
  end
end
