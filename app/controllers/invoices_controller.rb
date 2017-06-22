class InvoicesController < ApplicationController
  def new
    @invoice = Invoice.new_for(current_user)
  end

  def create
    @invoice = Invoice.new(invoice_params.merge(user: current_user))
    if @invoice.save
      redirect_to invoices_path
    else
      render :new
    end
  end

  def edit
    @invoice = current_user.invoices.find(params[:id])
  end

  def update
    @invoice = current_user.invoices.find(params[:id])
    if @invoice.update(invoice_params)
      redirect_to invoices_path
    else
      render :edit
    end
  end


  def show
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      format.html { render 'show', layout: 'pdf' }
      format.pdf do
        render :pdf => "invoice_#{@invoice.tax_date.strftime('%Y%m%d')}",
          :template => 'invoices/preview',
          :handlers => %w[erb],
          :formats => %w[html],
          # :stylesheets => %w[application],
          :layout => 'pdf',
          # :locals => { :foo => 'bar' },
          :disposition => 'inline', # PDF will be sent inline, means you can load it inside an iFrame or Embed
          :relative_paths => true # Modify asset paths to make them relative. See [the AssetSupport module](/lib/princely/asset_support.rb)
      end
    end
  end

  def index
    @invoices = current_user.invoices.order(created_at: :desc).page(params[:page])
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
      :account_name,
      :account_number,
      :account_sort,
      :notes,
      :recipients,
      data_rows: [:description, :rate, :quantity, :vat_percentage],
    )
  end
end
