class CreateTaxes < ActiveRecord::Migration[5.0]
  def change
    create_table :taxes do |t|
      t.references :user
      t.date :period_end, index: true
      t.string :tax_type
      t.decimal :amount, precision: 8, scale: 2

      t.timestamps
    end
  end
end
