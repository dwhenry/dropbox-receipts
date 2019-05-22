class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.boolean :primary

      t.timestamps
    end
    
    User.all.each do |user|
      Company.create!(id: user.id, user_id: user.id, name: user.company_name, primary: true)
    end

    %w[bank_lines dividends invoices manual_matches receipts].each do |table_name|
      rename_column table_name, :user_id, :company_id
    end
  end
end
