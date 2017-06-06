class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate

  private

  def authenticate
    user || redirect_to '/auth/dropbox_oauth2'
    @session[:last_access] = Time.now.to_i
  end

  def user
    @session.fetch(:last_access, 0) >= 7.days.ago.to_i
    @user || User.find_by(id: @session[:user_id])
  end
end
