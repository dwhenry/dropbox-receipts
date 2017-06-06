class AuthController < ApplicationController
  before_action :authenticate

  def success

  end

  def logout
    @session[:user_id] = nil
    @session[:last_access] = nil
  end

  def failure
    render text: "did not work:\n#{params.inspect}"
  end
end
