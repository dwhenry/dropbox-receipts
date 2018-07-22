class ManualMatch < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'ManualMatch') }, class_name: "BankLine", foreign_key: :source_id
  scope :without_source, -> do
    left_joins(:lines).where(
      <<~SQL
        bank_lines.id IS NULL OR
          manual_matches.amount NOT IN (
            SELECT SUM(amount * -1)
            FROM bank_lines AS bl
            WHERE bl.source_id = manual_matches.id 
              AND bl.source_type = 'ManualMatch'
          )
      SQL
    )
  end

  validates :amount, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :payment_type, presence: true
  validates :payment_subtype, presence: true

  def desc
    "Manual: #{payment_type}: #{payment_subtype}"
  end

  def link_action
    'edit'
  end
end
