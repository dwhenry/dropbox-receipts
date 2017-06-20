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
    @receipt = Receipt.find(params[:id])
    @types = ExpenseType.all

    respond_to do |format|
      format.js { render :edit, layout: false }
      format.html_safe? { render text: 'Broken' }
    end
  end

  def update
    receipt = Receipt.find(params[:id])
    receipt.update(receipt_params)
    DropboxMover.perform_async(@receipt.id)

    session[:flash] = "Receipt succcessfully uploaded!"
    redirect_to receipts_path
  end

  def index
    @receipts = current_user.receipts.order(created_at: :desc).page(params[:page])
  end

  def destroy
    receipt = Receipt.find(params[:id])
    receipt.update!(deleted: true)

    redirect_to receipts_path
  end

  private

  def receipt_params
    params.require(:receipt).permit(:company, :code, :amount, :purchase_date)
  end
end
