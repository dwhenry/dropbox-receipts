class UsersController < ApplicationController
  before_action :ensure_accountant

  def update
    user = User.find(params[:id])
    user.update!(is_accountant: !user.is_accountant)

    session[:flash] = "#{user.name} succcessfully updated!"
    redirect_to users_path
  end

  def index
    @users = User.order(:name).page(params[:page])
  end

  private

  def ensure_accountant
    redirect_to root_path unless current_user.is_accountant?
  end
end
