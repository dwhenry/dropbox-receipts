class Receipt < ApplicationRecord
  belongs_to :user
  default_scope { where(deleted: false) }

  def build_path
    [
      'receipts',
      created_at.strftime('%Y-%m'),
      [
        created_at.strftime('%d%b %H%M%S'),
        code,
        purchase_date.strftime('%Y-%m-%d'),
        id,
        'jpeg'
      ].compact.join('.')
    ].compact.join('/')
  end
end
