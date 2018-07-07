class CreateDividends < ActiveRecord::Migration[5.0]
  def change
    create_table :dividends do |t|
      t.references :user, foreign_key: true
      t.date :dividend_date
      t.decimal :total_amount, precision: 8, scale: 2
      t.jsonb :data_rows
      t.datetime :generated_at
      t.datetime :sent_at
      t.text :recipients
      t.string :company_name
      t.string :company_reg

      t.timestamps
    end
  end
end
