class Receipt < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'Receipt') }, class_name: "BankLine", foreign_key: :source_id
  has_one :line, -> { where(source_type: 'Receipt') }, class_name: "BankLine", foreign_key: :source_id
  validates_presence_of :user

  default_scope { where(deleted: false) }
  scope :without_source, -> { left_joins(:lines).where(bank_lines: { id: nil }) }
  scope :before_date, ->(date) { without_source.where(purchase_date: date-30..date).order(purchase_date: :desc) }

  def desc
    "Receipt: #{code}"
  end

  def link_action
    'edit'
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
