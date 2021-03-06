class AuthController < ApplicationController
  skip_before_action :authenticate, only: [:success, :failure, :logout]

  def success
    user = User.from_oauth(env['omniauth.auth'])
    session[:user_id] = user.id
    session[:last_access] = Time.now.to_i
    redirect_to session[:redirect_path]
  end

  def logout
    session[:user_id] = nil
    session[:last_access] = nil
  end

  def failure
    render text: "did not work:\n#{params.inspect}"
  end

  def company
    session[:company_id] = params[:company_id]
    redirect_to request.referrer
  end
end
