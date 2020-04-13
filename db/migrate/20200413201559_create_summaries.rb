class CreateSummaries < ActiveRecord::Migration[5.0]
  def change
    create_table :summaries do |t|
      t.date :for
      t.references :company, foreign_key: true
      t.references :last_receipt, foreign_key: { to_table: :receipts, null: true }
      t.references :last_manual, foreign_key: { to_table: :manual_matches, null: true }

      t.timestamps
    end
  end
end
