class ManualMatch < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'ManualMatch') }, class_name: "BankLine", foreign_key: :source_id
  scope :without_source, -> { left_joins(:lines).where(bank_lines: { id: nil }) }

  validates :amount, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :payment_type, presence: true
  validates :payment_subtype, presence: true

  def desc
    "Manual: #{payment_type}:#{payment_subtype}"
  end

  def link_action
    'edit'
  end
end
