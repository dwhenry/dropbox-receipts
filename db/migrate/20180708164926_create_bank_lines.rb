class CreateBankLines < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_lines do |t|
      t.string :name, index: true
      t.string :account_num, index: true
      t.string :sort_code, index: true
      t.references :previous, references: :bank_lines
      t.references :user, foreign_key: true
      t.decimal :amount, precision: 8, scale: 2
      t.decimal :balance, precision: 8, scale: 2
      t.date :transaction_date
      t.string :description
      t.string :transaction_type
      t.references :source
      t.string :source_type, index: true

      t.timestamps
    end
  end
end
