class Receipt < ApplicationRecord
  belongs_to :user
  validates_presence_of :user

  default_scope { where(deleted: false) }

  def desc
    "Receipt: #{code}-#{created_at.strftime('%Y-%m')}"
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
