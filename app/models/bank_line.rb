class BankLine < ApplicationRecord
  has_one :next, required: false, class_name: 'BankLine', foreign_key: 'previous_id'
  belongs_to :previous, required: false, class_name: 'BankLine'
  belongs_to :user

  validates :previous, presence: true, unless: ->(line) { line.description == 'Opening Balance' }
  validates :user, presence: true
  validates :balance,
    inclusion: {
      in: ->(line) { [(line.previous&.balance || 0) + (line.amount || 0)] },
      message: 'does not match expectation. (previous balance + change)'
    }
  validates :name, presence: true
  validates :account_num, presence: true
  validates :sort_code, presence: true
  validates :transaction_date, presence: true
  validates :description,
    uniqueness: {
      scope: [:user_id, :name],
      message: 'can only be opened once',
      if: ->(line) { line.description == 'Opening Balance' }
    },
    presence: true
  validates :transaction_type, presence: true
  # validates :transaction_date, numericality: { greater_than_or_equal_to: ->(line) { line.previous.transaction_date } }

  def current_balance
    BankLine.left_joins(:next).find_by!(user_id: user_id, name: name, nexts_bank_lines: { id: nil }).balance
  end

  def initialize_next(data)
    self.class.new(
      name: name,
      account_num: account_num,
      sort_code: sort_code,
      user: user,
      previous: self,
      transaction_date: data['Date'],
      transaction_type: data['Type'],
      description: data['Description'],
      amount: (data['Paid out'].to_d * -1) + data['Paid in'].to_d,
      balance: data['Balance']
    )
  end
end
