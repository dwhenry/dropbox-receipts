require 'csv'

class BankAccountsController < ApplicationController
  def new
    @bank_line = BankLine.new
  end

  def export
    BankAccountExporter.perform_async(params[:id], current_company.id)

    session[:flash] = "Bank Statement will be emailed shortly"

    redirect_to bank_account_path(params[:id])
  end

  def create
    # build opening balance
    @bank_line = BankLine.new(new_bank_line_params)
    if @bank_line.save
      # import the csv
      importer = CsvImporter.new(company: current_company, account_name: @bank_line.name)
      importer.import(params[:file]&.read || '')
      redirect_to bank_accounts_path(anchor: "account-#{@bank_line.name}"), flash: { @bank_line.name => importer.errors }
    else
      @bank_lines = bank_lines.where(name: params[:id]).order(:created_at, :previous_id).page(params[:page])
      render :new
    end
  end

  def show
    raw_lines = bank_lines.where(name: params[:id])
    @manual_types = ManualMatch
      .distinct
      .order(:payment_type, :payment_subtype)
      .select(
        "concat(payment_type, ': ', payment_subtype) as name",
        "concat(payment_type, ':', payment_subtype) as key",
        :payment_type, :payment_subtype
      )
    lines = raw_lines
    if params[:filter] == 'unlinked'
      lines = lines.where(source_id: nil)
    elsif params[:filter].present?
      lines = lines.where(source_id: nil).where('bank_lines.description ilike ?', "%#{params[:filter]}%")
    end
    if lines.empty?
      lines = raw_lines
      params[:filter] = nil
    end
    @bank_lines = lines.order(:created_at, :previous_id).page(params[:page])
  end

  def update
    ActiveRecord::Base.transaction do
      if params[:filter].blank? || params[:filter] == 'unlinked'
        flash[:danger] = "No update as missing filter"
      else
        lines = bank_lines.where(name: params[:id]).where(source_id: nil).where('bank_lines.description ilike ?', "%#{params[:filter]}%")

        case params[:type]
        when 'manual'
          payment_type, payment_subtype = (params[:new_payment_types].presence || params[:payment_types]).split(':')
          lines.each do |line|
            manual_match = ManualMatch.create!(
              date: line.transaction_date,
              payment_type: payment_type,
              payment_subtype: payment_subtype,
              amount: line.amount.abs,
              company: current_company
            )

            line.update!(source: manual_match)
            ManualProcessor.perform_async(manual_match.id)
          end
        when 'dividends'
          prev_dividends = Dividend.where(company_id: current_company.id).order(dividend_date: :desc)
          prev_dividend = prev_dividends.last
          lines_array = lines.to_a
          params[:groups].split(',').map(&:to_i).each do |group_size|
            div_lines = lines_array.shift(group_size)
            break if div_lines.count != group_size
            data_rows = div_lines.map do |line|
              previous = BankLine
                .where(source_id: prev_dividends, source_type: 'Dividend', company_id: current_company.id)
                .where("bank_lines.description ilike ? or ? ilike '%' || bank_lines.description || '%'", "%#{line.description}%", line.description)
                .order(transaction_date: :desc)
                .limit(10).to_a

              if previous.empty?
                flash[:warning] = "Unable to find a previous dividend matching the description"
                binding.pry
                break
              end

              row = nil
              previous.detect do |p|
                rows = p.source.data_rows.select {|row| row['amount'].to_f == p.amount.abs}
                row = rows.first if rows.count == 1
              end
              if row.blank?
                flash[:warning] = "Unable to find a select shareholder based on previous dividends"
                binding.pry
                break
              end
              {
                shareholder: row['shareholder'],
                shares: row['shares'],
                amount: line.amount.abs
              }
            end
            binding.pry

            dividend = Dividend.create!(
              company_name: prev_dividend.company_name,
              company_reg: prev_dividend.company_name,
              dividend_date: div_lines.map(&:transaction_date).max,
              data_rows: data_rows,
              company: current_company
            )
            div_lines.each {|l| l.update!(source: dividend) }
            DividendProcessor.perform_async(dividend.id)
          end
        end
      end

      redirect_to bank_account_path(params[:id])
    end
  end

  def index
    @bank_accounts = bank_accounts
  end

  def import
    importer = CsvImporter.new(company: current_company, account_name: params[:account_name])
    importer.import(params[:file]&.read || '')

    redirect_to bank_accounts_path(anchor: "account-#{params[:account_name]}"), flash: { params[:account_name] => importer.errors }
  end

  def destroy
    lines = bank_lines.where(name: params[:id])
    lines.delete_all

    redirect_to bank_accounts_path
  end

  private

  def bank_lines
    current_user.is_accountant? ? BankLine.order(id: :desc) : current_company.bank_lines.order(id: :desc)
  end

  def bank_accounts
    bank_lines.select(:name, :account_num, :sort_code, :company_id).includes(:company).reorder(:name).distinct
  end

  def new_bank_line_params
    params.require(:bank_line).permit(
      :name,
      :account_num,
      :sort_code,
      :balance,
      :transaction_date
    ).tap do |p|
      p[:amount] = p[:balance]
      p[:description] = 'Opening Balance'
      p[:transaction_type] = 'OPN'
      p[:company] = current_company
    end
  end

  class HsbcPresenter
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def description
      line['Description']
    end

    def date
      line['Date']
    end

    def type
      line['Type']
    end

    def balance
      line['Balance']
    end

    def amount
      (data['Paid out'].to_d * -1) + data['Paid in'].to_d
    end
  end

  class TidePresenter
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def description
      line['Transaction description']
    end

    def date
      line['Date']
    end

    def type
      line['Transaction type']
    end

    def balance
      nil
    end

    def amount
      line['Amount']
    end
  end

  class CsvImporter
    attr_reader :errors, :presenter

    def initialize(company:, account_name:, presenter: TidePresenter)
      @company = company
      @account_name = account_name
      @presenter = presenter
      @errors = []
    end

    def import(io)
      skip = false
      skipped = []
      processed = []
      ApplicationRecord.transaction do
        CSV.parse(io, headers: true).map do |line|
          presenter.new(line)
        end
          .sort_by { |line| line.date }
          .each do |pline|
            if skip
              skipped << pline.description
              next
            end

            next_line = current.initialize_next(pline)

            if next_line.save
              @current = next_line
              processed << next_line.id
            else
              @errors += next_line.errors.full_messages
              skip = true
            end
          end

        raise ActiveRecord::Rollback if @errors.any?
      end

      @errors << "Skipped #{skipped.count} lines: (#{skipped.join(', ')})" if skipped.any?

      # do matching in the background
      BankStmtLookup.perform_async(processed) if @errors.empty?
    end

    def current
      @current ||= @company.bank_lines
        .where(name: @account_name)
        .left_joins(:next).where(nexts_bank_lines: { id: nil })
        .first
    end
  end
end
