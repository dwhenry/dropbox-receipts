class Receipt < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'Dividend') }, class_name: "BankLine", foreign_key: :source_id
  has_one :lines, -> { where(source_type: 'Dividend') }, class_name: "BankLine", foreign_key: :source_id
  validates_presence_of :user

  default_scope { where(deleted: false) }
  scope :without_source, -> { left_joins(:lines).where(bank_lines: { id: nil }) }

  def desc
    "Receipt: #{code}"
  end

  def build_path
    '/' + [
      Rails.env.production? ? nil : Rails.env,
      'receipts',
      created_at.strftime('%Y-%m'),
      [
        created_at.strftime('%d%b-%H%M%S'),
        code || 'PEN',
        purchase_date.strftime('%Y-%m-%d'),
        id,
        'jpeg'
      ].join('.')
    ].compact.join('/')
  end

  def month
    "#{purchase_date.month}-#{purchase_date.year}"
  end
end
