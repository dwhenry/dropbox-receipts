class Invoice < ApplicationRecord
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :company_name
  validates_presence_of :tax_date
  validates_presence_of :terms
  validate :locked_after_generation

  default_scope { where(deleted: false) }

  CLONE_ATTR = [
    'to_address',
    'company_name',
    'company_address',
    'company_reg',
    'company_vat',
    'number',
    'terms',
    'data_rows',
    'reference',
  ]

  def self.new_for(user)
    last_invoice = user.invoices.order(created_at: :desc).first
    if last_invoice
      new(last_invoice.attributes.slice(*CLONE_ATTR).merge(tax_date: Date.today))
    else
      new(tax_date: Date.today)
    end
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

  def locked_after_generation
    if generated_at
      if changed - [:updated_at, :deleted]
        errors.add(:base, 'Can not modify generated invoice')
      end
    end
  end

  def due_date
    super || (terms && tax_date && tax_date.advance(days: terms.to_i))
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
