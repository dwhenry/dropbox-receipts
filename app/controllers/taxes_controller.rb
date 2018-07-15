class TaxesController < ApplicationController
  def new
    @tax = Tax.new
  end

  def create
    @tax = Tax.new(tax_params.merge(user: current_user))
    if @tax.save
      redirect_to taxes_path
    else
      render :new
    end
  end

  def index
    @taxes = taxes.order(period_end: :desc).page(params[:page])
  end

  # def edit
  #   @tax = taxes.find(params[:id])
  # end

  private

  def taxes
    current_user.is_accountant? ? Tax : current_user.taxes
  end

  def tax_params
    params.require(:tax).permit(
      :period_end,
      :tax_type,
      :amount,
    )
  end
end
