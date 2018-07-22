class ManualMatch < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'ManualMatch') }, class_name: "BankLine", foreign_key: :source_id
  scope :without_source, -> { left_joins(:lines).where("bank_lines.id is null OR manual_matches.amount NOT in (select sum(amount) from bank_lines as bl where bl.source_id = manual_matches.id and bl.source_type = 'ManualMatch')") }

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
