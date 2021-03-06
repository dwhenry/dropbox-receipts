class BankLine < ApplicationRecord

  def formatted
    @formatted ||= Formatted.new(self)
  end

  has_one :next, required: false, class_name: 'BankLine', foreign_key: 'previous_id'
  belongs_to :previous, required: false, class_name: 'BankLine'
  belongs_to :company
  # delegate :user, to: :company
  belongs_to :source, polymorphic: true, required: false

  belongs_to :parent, class_name: 'BankLine', optional: true
  has_many :children, foreign_key: :parent_id, class_name: 'BankLine'
  validates :previous, presence: true, unless: ->(line) { line.description == 'Opening Balance' }
  # validates :user, presence: true
  validates :company, presence: true
  validates :balance,
    inclusion: {
      in: ->(line) { [(line.previous&.balance || 0) + (line.amount || 0)] },
      message: ->(line, _) do
        "does not match expectation. (#{line.description}: #{line.formatted.prev_balance} + #{line.formatted.amount} <> #{line.formatted.balance})"
      end
    }
  validates :name, presence: true
  validates :account_num, presence: true
  validates :sort_code, presence: true
  validates :transaction_date, presence: true
  validates :description,
    uniqueness: {
      scope: [:company_id, :name],
      message: 'can only be opened once',
      if: ->(line) { line.description == 'Opening Balance' }
    },
    presence: true
  validates :transaction_type, presence: true
  validate do |line|
    !line.previous || line.transaction_date >= line.previous.transaction_date
  end

  def current_balance
    BankLine.left_joins(:next).find_by!(company_id: company_id, name: name, nexts_bank_lines: { id: nil }).balance
  end

  def initialize_next(data)
    self.class.new(
      name: name,
      account_num: account_num,
      sort_code: sort_code,
      company: company,
      previous: self,
      transaction_date: data.date,
      transaction_type: data.type,
      description: data.description,
      amount: data.amount,
      balance: data.balance.presence || balance + data.amount.to_f # balance is blank when multiple transaction on one day
    )
  end

  def force_match(params)
    # TODO: we should do some sort additional checks here
    # maybe something about ensuring no duplicate matches, etc..
    return false unless params[:source_id].present? && params[:source_type].present?
    update(params)
  end

  def clear_match
    update(source_type: nil, source_id: nil)
  end

  class Formatted
    include ActionView::Helpers::NumberHelper

    def initialize(base)
      @base = base
    end

    def prev_balance
      number_to_currency(@base.previous.balance, unit: '£')
    end

    def amount
      number_to_currency(@base.amount, unit: '£')
    end

    def balance
      number_to_currency(@base.balance, unit: '£')
    end
  end
end
