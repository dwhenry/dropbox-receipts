class Receipt < ApplicationRecord
  belongs_to :company
  # delegate :user, to: :company
  has_many :lines, -> { where(source_type: 'Receipt') }, class_name: "BankLine", foreign_key: :source_id
  has_one :line, -> { where(source_type: 'Receipt') }, class_name: "BankLine", foreign_key: :source_id
  validates_presence_of :company

  default_scope { where(deleted: false) }
  scope :without_source, -> { left_joins(:lines).where(bank_lines: { id: nil }) }
  scope :before_date, ->(date) do
    without_source
      .where.not(payer: 'individual')
      .where(purchase_date: date-30..date)
      .order(purchase_date: :desc)
  end

  def desc
    "Receipt: #{code}"
  end

  def link_action
    'edit'
  end

  def build_path
    '/' + [
      Rails.env.production? ? nil : Rails.env,
      company.primary ? nil : company.name,
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

  def code_name
    ExpenseType.lookup(code)
  end

  def month
    "#{purchase_date.month}-#{purchase_date.year}"
  end
end
