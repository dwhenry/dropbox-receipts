class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.references :user, foreign_key: true
      t.text :to_address
      t.string :company_name
      t.text :company_address
      t.string :company_reg
      t.string :company_vat
      t.string :number
      t.date :tax_date
      t.string :po_number
      t.string :terms
      t.date :due_date
      t.datetime :generated_at
      t.boolean :deleted, default: false
      t.jsonb :data_rows

      t.timestamps
    end
  end
end
