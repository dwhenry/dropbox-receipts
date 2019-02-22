require 'dropbox'

class BankAccountExporter
  include Sidekiq::Worker
  include ActionView::Helpers::NumberHelper

  def perform(bank_account_name, user_id)
    @user_id = user_id

    year = Date.today.year
    year -= 1 if Date.parse("#{year}-06-30") > Date.today
    period = Date.parse("#{year-1}-07-01")..Date.parse("#{year}-06-30")

    lines = bank_lines
              .where(name: bank_account_name)
              .where(transaction_date: period)
              .order(:created_at, :previous_id)

    titles = [
      'Date',
      'Type',
      'Description',
      'Paid In',
      'Paid Out',
      'Balance',
      'Linked',
      'Dropbox Location',
    ].join(",")

    data = lines.map do |line|
      [
        line.transaction_date.strftime('%d %b %Y'),
        line.transaction_type,
        line.amount > 0 ? number_to_currency(line.amount, unit: '£') : nil,
        line.amount < 0 ? number_to_currency(line.amount.abs, unit: '£') : nil,
        number_to_currency(line.balance, unit: '£'),
        line.source&.desc,
        line.source.try(:build_path)
      ].join(",")
    end

    BankAccountMailer.business_statement_email(user, bank_account_name, year, [title, *data].join("\n")).deliver
  end

  def bank_lines
    user.is_accountant? ? BankLine.order(id: :desc) : user.bank_lines.order(id: :desc)
  end

  def user
    @user ||= User.find(@user_id)
  end
end
