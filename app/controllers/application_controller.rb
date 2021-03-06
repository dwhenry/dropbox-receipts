class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate
  helper_method :current_user, :current_company

  private

  def authenticate
    if current_user
      session[:last_access] = Time.now.to_i
    else
      session[:user_id] = nil
      session[:last_access] = nil
      session[:redirect_path] = request.fullpath
      redirect_to('/auth/dropbox_oauth2')
    end
  end

  def current_user
    (session[:last_access] || 0) >= 30.days.ago.to_i
    if Rails.env.development?
      User.find(3)
    else
      @user || User.find_by(id: session[:user_id])
    end
  end

  def current_company
    if session[:company_id]
      company = current_user.companies.find_by(id: session[:company_id])
      unless company
        session[:company_id] = nil
        redirect_to request.referrer
      end
      company
    else
      current_user.companies.primary
    end
  end
end
