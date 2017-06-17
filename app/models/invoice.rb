class Invoice < ApplicationRecord
  belongs_to :user

  validates_presence_of :company_name
  validates_presence_of :tax_date
  validates_presence_of :terms
  validate :locked_after_generation


  def address_lines(field)
    (self[field] || 'N/A').split('\n').each do |line|
      yield line
    end
  end

  def rows
    @rows ||= (data_rows || []).map { |row| Row.new(row) }
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

  class Row
    attr_reader :description, :rate, :quantity, :gross

    def initialize(description:, rate:, quantity:, gross:)
      @description = description
      @rate = rate
      @quantity = quantity
      @gross = gross
    end
  end
end
