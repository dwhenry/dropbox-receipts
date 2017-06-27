class AddUserFields < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :is_accountant, :boolean
  end
end
