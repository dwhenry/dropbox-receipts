class Dividend < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'Dividend') }, class_name: "BankLine", foreign_key: :source_id

  validates :dividend_date, presence: true
  validates :company_name, presence: true
  validates :company_reg, presence: true
  before_save :set_total_amount
  validate :valid_rows

  scope :without_source, -> do
    left_joins(:lines).where(
      <<~SQL
        bank_lines.id IS NULL OR
          dividends.total_amount NOT IN (
            SELECT SUM(amount * -1)
            FROM bank_lines AS bl
            WHERE bl.source_id = dividend.id
              AND bl.source_type = 'Dividend'
          )
      SQL
    )
  end

  CLONE_ATTR = %w{
    company_name
    company_reg
    data_rows
  }.freeze

  def self.new_for(user)
    last_dividend = user.dividends.order(created_at: :desc).first
    if last_dividend
      new(last_dividend.attributes.slice(*CLONE_ATTR).merge(dividend_date: Date.today))
    else
      new(dividend_date: Date.today)
    end
  end

  def desc
    "Dividend: #{dividend_date}"
  end

  def link_action
    'show'
  end

  def rows
    @rows ||= (data_rows || [{}]).map { |row| Row.new(row.symbolize_keys) }
  end

  def tax_year
    if dividend_date.month > 4 || (dividend_date.month == 4 && dividend_date.day > 4)
      "#{dividend_date.year}/#{dividend_date.year + 1}"
    else
      "#{dividend_date.year - 1}/#{dividend_date.year}"
    end
  end

  def split_lines(field)
    (self[field] || 'N/A').split("\n").each do |line|
      yield line
    end
  end

  def build_path
    '/' + [
      Rails.env.production? ? nil : Rails.env,
      'dividends',
      filename
    ].compact.join('/')
  end

  def filename
    [
      'dividend',
      dividend_date.strftime('%Y%m%d'),
      'pdf'
    ].join('.')
  end

  private

  def set_total_amount
    self.total_amount = rows.sum { |row| row.amount || 0 }
  end

  def valid_rows
    errors.add(:data_row, 'invalid details') unless rows.all?(&:valid?)
  end

  class Row
    include ActiveModel
    include ActiveModel::Validations
    attr_reader :shareholder, :shares, :amount

    validates :shareholder, presence: true
    validates :shares, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }

    def initialize(shareholder: nil, shares: nil, amount: nil)
      @shareholder = shareholder
      @shares = shares
      @amount = amount&.to_d
    end
  end
end
