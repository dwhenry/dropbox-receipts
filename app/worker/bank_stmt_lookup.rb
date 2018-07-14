class BankStmtLookup
  include Sidekiq::Worker
  class GetFailed < StandardError; end

  def perform(bank_line_ids)
    ApplicationRecord.transaction do
      bank_line_ids.each do |bank_line_id|
        lookup(bank_line_id)
      end
    end
  end

  def lookup(bank_line_id)
    line = BankLine.find(bank_line_id)

    case line.transaction_type
    when 'CR'
      find_invoice(line)
    when 'BP', 'SO'
      find_dividend(line) || find_wage(line) || find_tax(line)
    when 'DR', 'VIS', 'DD', ')))'
      find_receipt(line)
    else
      raise "Unknown type: #{line.transaction_type}"
    end

    line.save!
  end

  def find_invoice(line)
    invoice = Invoice.where(
      due_date: line.transaction_date,
    ).where.not(
      id: BankLine.where(source_type: 'Invoice').pluck(:source_id)
    ).detect { |row| row.gross == line.amount }

    line.source = invoice
  end

  def find_dividend(line)
    dividends = Dividend.where(
      dividend_date: line.transaction_date,
    )
    selected = dividends.detect do |dividend|
      amounts = BankLine.where(source_type: 'Dividend', source_id: dividend.id).pluck(:amount)
      (dividend.rows.map(&:amount) - amounts).include?(line.amount.abs)
    end

    line.source = selected
  end

  def find_wage(line)

  end

  def find_tax(line)

  end

  def find_receipt(line)
    receipt = Receipt.where(
      purchase_date: line.transaction_date,
    ).where.not(
      id: BankLine.where(source_type: 'Receipt').pluck(:source_id)
    ).first

    line.source = receipt
  end
end
