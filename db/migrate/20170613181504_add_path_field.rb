class AddPathField < ActiveRecord::Migration[5.0]
  def change
    add_column :receipts, :path, :string, limit: 511
  end
end
