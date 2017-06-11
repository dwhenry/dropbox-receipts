class CreateReceipts < ActiveRecord::Migration[5.0]
  def change
    create_table :receipts do |t|
      t.references :user, foreign_key: true
      t.binary :image
      t.date :purchase_date
      t.string :code
      t.decimal :amount, precision: 8, scale: 2

      t.timestamps
    end
  end
end
