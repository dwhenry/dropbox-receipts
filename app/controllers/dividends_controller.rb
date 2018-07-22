class DividendsController < ApplicationController
  def new
    @dividend = Dividend.new_for(current_user)
  end

  def create
    @dividend = Dividend.new(dividend_params.merge(user: current_user))
    if @dividend.save
      redirect_to dividends_path
    else
      render :new
    end
  end

  def edit
    @dividend = dividends.find(params[:id])
  end

  def update
    @dividend = dividends.find(params[:id])
    if @dividend.update(dividend_params)
      redirect_to dividends_path
    else
      render :edit
    end
  end


  def show
    @dividend = dividends.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        render(
          pdf: "dividend_#{@dividend.dividend_date.strftime('%Y%m%d')}",
          template: 'dividends/preview',
          layout: 'pdf',
          zoom: 3
        )
      end
    end
  end

  def index
    @dividends = dividends.order(dividend_date: :desc).page(params[:page])
  end

  def generate
    dividend = dividends.find(params[:id])
    DividendProcessor.perform_async(dividend.id)
    redirect_to dividends_path
  end

  private

  def dividend_params
    params.require(:dividend).permit(
      :company_name,
      :company_reg,
      :dividend_date,
      data_rows: [:shareholder, :shares, :amount],
    )
  end

  def dividends
    current_user.is_accountant? ? Dividend : current_user.dividends
  end
end
