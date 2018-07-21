class RenameTaxesToManualMatch < ActiveRecord::Migration[5.0]
  def change
    rename_table :taxes, :manual_matches

    rename_column :manual_matches, :period_end, :date
    rename_column :manual_matches, :tax_type, :payment_type

    add_column :manual_matches, :payment_subtype, :string

    execute <<~SQL
      UPDATE manual_matches
      SET payment_subtype = payment_type,
        payment_type = 'Tax'
    SQL
  end
end
