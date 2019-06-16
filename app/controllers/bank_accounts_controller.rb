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
    lines = bank_lines.where(name: params[:id])

    case params[:filter]
    when 'unlinked'
      lines = lines.where(source_id: nil)
    end

    @bank_lines = lines.order(:created_at, :previous_id).page(params[:page])
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
