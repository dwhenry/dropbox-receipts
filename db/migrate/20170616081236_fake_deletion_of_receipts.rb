class FakeDeletionOfReceipts < ActiveRecord::Migration[5.0]
  def change
    add_column :receipts, :deleted, :boolean, default: false
  end
end
