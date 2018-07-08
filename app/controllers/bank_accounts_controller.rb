require 'csv'

class BankAccountsController < ApplicationController
  def new
    @bank_line = BankLine.new
  end

  def create
    # build opening balance
    @bank_line = BankLine.new(new_bank_line_params)
    if @bank_line.save
      # import the csv
      importer = CsvImporter.new(user: current_user, account_name: @bank_line.name)
      importer.import(params[:file]&.read || '')
      redirect_to bank_accounts_path(anchor: "account-#{@bank_line.name}"), flash: { @bank_line.name => importer.errors }
    else
      render :new
    end
  end

  def show
    @bank_lines = bank_lines.where(name: params[:id]).order(:created_at, :previous_id).page(params[:page])
  end

  def index
    @bank_accounts = bank_accounts
  end

  def import
    importer = CsvImporter.new(user: current_user, account_name: params[:account_name])
    importer.import(params[:file]&.read || '')
    redirect_to bank_accounts_path(anchor: "account-#{params[:account_name]}"), flash: { params[:account_name] => importer.errors }
  end

  def bank_lines
    current_user.is_accountant? ? BankLine : current_user.bank_lines
  end

  def bank_accounts
    bank_lines.select(:name, :account_num, :sort_code, :user_id).includes(:user).distinct
  end

  private

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
      p[:user] = current_user
    end
  end

  class CsvImporter
    attr_reader :errors

    def initialize(user:, account_name:)
      @user = user
      @account_name = account_name
      @errors = []
    end

    def import(io)
      skip = false
      skipped = 0
      processed = []
      CSV.parse(io, headers: true).each do |line|
        if skip
          skipped += 1
          next
        end

        next_line = current.initialize_next(line)
        if next_line.save
          @current = next_line
          processed << next_line.id
        else
          @errors += next_line.errors.full_messages
          skip = true
        end
      end

      # do matching in the background
      # processed

      @errors << "Skipped #{skipped} lines" if skipped > 0
    end

    def current
      @current ||= @user.bank_lines
        .where(name: @account_name)
        .left_joins(:next).where(nexts_bank_lines: { id: nil })
        .first
    end
  end
end
