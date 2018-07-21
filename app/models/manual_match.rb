class ManualMatch < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'ManualMatch') }, class_name: "BankLine", foreign_key: :source_id
  scope :without_source, -> { left_joins(:lines).where(bank_lines: { id: nil }) }
end
