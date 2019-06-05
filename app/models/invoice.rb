class Invoice < ApplicationRecord
  belongs_to :company
  has_many :bank_lines, as: :source
  has_many :lines, -> { where(source_type: 'Invoice') }, class_name: "BankLine", foreign_key: :source_id
  has_one :line, -> { where(source_type: 'Invoice') }, class_name: "BankLine", foreign_key: :source_id

  validates_presence_of :company
  validates_presence_of :company_name
  validates_presence_of :tax_date
  validates_presence_of :terms
  validate :locked_after_generation
  validates :number, uniqueness: { scope: :company_id }

  default_scope { where(deleted: false) }
  scope   :without_source, -> { left_joins(:lines).where(bank_lines: { id: nil }) }

  CLONE_ATTR = %w{
    to_address
    company_name
    company_address
    company_reg
    company_vat
    number
    terms
    data_rows
    reference
    account_name
    account_number
    account_sort
    recipients
    notes
  }.freeze

  def self.new_for(company)
    last_invoice = company.invoices.order(created_at: :desc).first
    if last_invoice
      new(last_invoice.attributes.slice(*CLONE_ATTR).merge(tax_date: Date.today))
    else
      new(tax_date: Date.today)
    end
  end

  def desc
    "Invoice: #{number}"
  end

  def link_action
    'show'
  end

  def split_lines(field)
    (self[field] || 'N/A').split("\n").each do |line|
      yield line
    end
  end

  def rows
    @rows ||= (data_rows || [{}]).map { |row| Row.new(row.symbolize_keys) }
  end

  def net
    rows.sum(&:net)
  end

  def vat
    rows.sum(&:vat)
  end

  def gross
    rows.sum(&:gross)
  end

  def tax_year
    if tax_date.month > 4 || (tax_date.month == 4 && tax_date.day > 4)
      "#{tax_date.year}/#{tax_date.year + 1}"
    else
      "#{tax_date.year - 1}/#{tax_date.year}"
    end
  end

  def locked_after_generation
    if generated_at
      if (changed - %w{updated_at deleted generated_at sent_at}).any?
        errors.add(:base, 'Can not modify generated invoice')
      end
    end
  end

  def due_date
    super || (terms && tax_date && tax_date.advance(days: terms.to_i))
  end

  def build_path
    '/' + [
      Rails.env.production? ? nil : Rails.env,
      'invoices',
      filename
    ].compact.join('/')
  end

  def filename
    [
      'invoice',
      tax_date.strftime('%Y%m%d'),
      'pdf'
    ].join('.')
  end

  class Row
    attr_reader :description, :rate, :quantity, :vat_percentage

    def initialize(description: nil, rate: nil, quantity: 1.0, vat_percentage: 20.0)
      @description = description
      @rate = rate.to_f
      @quantity = quantity.to_f
      @vat_percentage = vat_percentage.to_f
    end

    def net
      ((rate || 0) * quantity).round(2)
    end

    def vat
      (net * vat_percentage / 100).round(2)
    end

    def gross
      net + vat
    end
  end
end
