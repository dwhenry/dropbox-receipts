class ReceiptsController < ApplicationController
  def new
  end

  def create
    receipt = Receipt.create!(user: current_user, image: params['img_data'])
    DropboxSaver.perform_async(receipt.id)
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
