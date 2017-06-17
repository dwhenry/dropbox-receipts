class InvoicesController < ApplicationController
  PAGESIZE = 20

  def new
    @invoice = Invoice.new(tax_date: Date.today)
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      redirect_to invoices_path
    else
      render :new
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def index
    @invoices = current_user.invoices.order(created_at: :desc).limit(PAGESIZE).offset(params[:page] || 0 * PAGESIZE)
  end

  private

  def invoice_params
    params.require(:invoice).permit(
      :to_address,
      :company_name,
      :company_address,
      :company_reg,
      :company_vat,
      :number,
      :tax_date,
      :po_number,
      :terms,
      :due_date,
      # data_rows: ,
    )
  end
end
