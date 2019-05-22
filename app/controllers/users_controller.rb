class UsersController < ApplicationController
  def update
    user = User.find(params[:id])
    user.update!(is_accountant: !user.is_accountant)

    session[:flash] = "#{user.name} succcessfully updated!"
    redirect_to users_path
  end

  def index
    scope = current_user.is_accountant? ? User : User.where(id: current_user.id)
    @users = scope.order(:name).page(params[:page])
  end
end
