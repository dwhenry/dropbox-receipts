class CompaniesController < ApplicationController
  def create
    company = current_user.companies.create!(name: params.dig(:company, :name))

    session[:flash] = "#{company.name} succcessfully created!"
    redirect_to users_path
  end
end
