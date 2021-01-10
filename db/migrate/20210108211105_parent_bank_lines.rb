class ParentBankLines < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_lines, :parent_id, :integer
  end
end
