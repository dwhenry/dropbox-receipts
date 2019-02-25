class ReceiptsController < ApplicationController
  def new
  end

  def gallery
  end

  def create
    shared = { user: current_user, image: params['img_data'], purchase_date: Date.today }
    @receipt = if params[:similar_to]
                 prev = Receipt.find(params[:similar_to].to_i)
                 Receipt.create!(prev.attributes.slice(:company, :code, :purchase_date, :payer).merge(shared))
               else
                 Receipt.create!(shared)
               end

    DropboxSaver.perform_async(@receipt.id)

    respond_to do |format|
      format.js do
        @types = ExpenseType.all
        render :edit, layout: false, format: 'html', content_type: 'application/html'
      end
      format.html_safe? { redirect_to edit_path(@receipt) }
    end
  end

  def edit
    @receipt = receipts.find(params[:id])
    @types = ExpenseType.all

    respond_to do |format|
      format.js { render :edit, layout: false }
      format.html do
        @show_image = true
        render :edit, show_image: true
      end
    end
  end

  def update
    receipt = receipts.find(params[:id])
    receipt.update(receipt_params)
    DropboxMover.perform_async(receipt.id)

    session[:flash] = "Receipt succcessfully uploaded!"
    if params[:similar]
      redirect_to new_receipt_path(similar_to: receipt.id)
    else
      redirect_to receipts_path
    end
  end

  def index
    order_by = 'created_at'
    order_by = params[:order_by] if %w{created_at purchase_date}.include?(params[:order_by])
    @receipts = receipts.order(order_by => :desc).page(params[:page])
    @receipts = @receipts.left_joins(:line).where(payer: 'company', bank_lines: { id: nil }) if params[:filter] == 'unlinked'
  end

  def destroy
    receipt = receipts.find(params[:id])
    receipt.update!(deleted: true)

    redirect_to receipts_path
  end

  private

  def receipt_params
    params.require(:receipt).permit(:company, :code, :amount, :purchase_date, :payer)
  end

  def receipts
    current_user.is_accountant? ? Receipt : current_user.receipts
  end
end
