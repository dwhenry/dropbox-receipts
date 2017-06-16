class ReceiptsController < ApplicationController
  def new
  end

  def create
    @receipt = Receipt.create!(user: current_user, image: params['img_data'], purchase_date: Date.today)
    @types = ExpenseType.all
    DropboxSaver.perform_async(@receipt.id)

    respond_to do |format|
      format.js { render :edit, layout: false }
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

    session[:flash] = "Receipt succcessfully uploaded!"
    redirect_to receipts_path
  end

  def index
    render json: Receipt.order(created_at: :desc)
  end

  private

  def receipt_params
    params.require(:receipt).permit(:company, :code, :amount, :purchase_date)
  end
end
