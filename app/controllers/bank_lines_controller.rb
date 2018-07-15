require 'csv'

class BankLinesController < ApplicationController
  def edit
    @bank_line = bank_lines.find(params[:id])
  end

  def update
    @bank_line = bank_lines.find(params[:id])
    if @bank_line.force_match(bank_line_params)
      redirect_to bank_account_path(@bank_line.name, flash: 'Unable to match record')
    else
      render :edit
    end
  end

  def destroy
    @bank_line = bank_lines.find(params[:id])
    if @bank_line.clear_match
      redirect_to bank_account_path(@bank_line.name)
    else
      render :edit
    end

  end

  private

  def bank_lines
    current_user.is_accountant? ? BankLine.order(id: :desc) : current_user.bank_lines.order(id: :desc)
  end


  def bank_line_params
    params.permit(
      :source_id,
      :source_type,
    )
  end
end
