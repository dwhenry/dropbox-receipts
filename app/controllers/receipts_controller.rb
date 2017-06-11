class ReceiptsController < ApplicationController
  def new
  end

  def create
    receipt = Receipt.create!(user: current_user)
    DropboxSaver.perform_async(params['img_data'], receipt)
    redirect_to edit_receipt_path(receipt)
  end

  def edit
    @receipt = Receipt.find(params[:id])
    @types = []
    if request.xhr?
      render :edit, layout: false
    end
  end

  def update
    binding.pry
  end
end
