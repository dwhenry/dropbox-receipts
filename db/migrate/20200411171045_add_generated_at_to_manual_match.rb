class AddGeneratedAtToManualMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :manual_matches, :generated_at, :datetime
  end
end
