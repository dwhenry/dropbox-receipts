class ReceiptsController < ApplicationController
  def new
  end

  def create
    @receipt = Receipt.create!(user: current_user, image: params['img_data'])
    DropboxSaver.perform_async(@receipt.id)

    respond_to do |format|
      format.js { render :edit, layout: false }
      format.html_safe? { redirect_to edit_path(@receipt) }
    end
  end

  def edit
    @receipt = Receipt.find(params[:id])
    @types = []

    respond_to do |format|
      format.js { render :edit, layout: false }
      format.html_safe? { render text: 'Broken' }
    end
  end

  def update
    binding.pry
  end
end
