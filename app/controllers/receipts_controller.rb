class ReceiptsController < ApplicationController
  def new
  end

  def gallery
  end

  def create
    @receipt = Receipt.create!(user: current_user, image: params['img_data'], purchase_date: Date.today)

    DropboxSaver.perform_async(@receipt.id)

    respond_to do |format|
      format.js do
        @types = ExpenseType.all
        render :edit, layout: false
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
    redirect_to receipts_path
  end

  def index
    @receipts = receipts.order(created_at: :desc).page(params[:page])
    @receipts = @receipts.left_joins(:line).where(bank_lines: { id: nil }) if params[:filter] == 'unlinked'
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
