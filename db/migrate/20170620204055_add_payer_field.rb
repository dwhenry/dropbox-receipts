class AddPayerField < ActiveRecord::Migration[5.0]
  def change
    add_column :receipts, :payer, :string
  end
end
