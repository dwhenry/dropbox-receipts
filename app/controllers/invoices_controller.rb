class InvoicesController < ApplicationController
  def new
    @invoice = Invoice.new_for(current_user)
  end

  def create
    @invoice = Invoice.new(invoice_params.merge(company: current_company))
    if @invoice.save
      redirect_to invoices_path
    else
      render :new
    end
  end

  def edit
    @invoice = invoices.find(params[:id])
  end

  def update
    @invoice = invoices.find(params[:id])
    if @invoice.update(invoice_params)
      redirect_to invoices_path
    else
      render :edit
    end
  end


  def show
    @invoice = invoices.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        render(
          pdf: "invoice_#{@invoice.tax_date.strftime('%Y%m%d')}",
          template: 'invoices/preview',
          layout: 'pdf',
          zoom: 3
        )
      end
    end
  end

  def index
    @invoices = invoices.includes(:lines).order(created_at: :desc).page(params[:page])
  end

  def generate
    invoice = invoices.find(params[:id])
    InvoiceProcessor.perform_async(invoice.id, invoice_url(invoice, format: 'pdf', skip_overlay: true))
    redirect_to invoices_path
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
      :reference,
      :account_name,
      :account_number,
      :account_sort,
      :notes,
      :recipients,
      data_rows: [:description, :rate, :quantity, :vat_percentage],
    )
  end

  def invoices
    current_user.is_accountant? ? Invoice : current_company.invoices
  end
end
