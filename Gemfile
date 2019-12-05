source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

source 'https://rubygems.org' do
  gem 'blazer'
  gem 'rails-assets-tether'
  gem 'bootstrap', '~> 4.3.1'
  gem 'coffee-rails', '~> 4.2'
  gem 'dropbox-sdk'
  gem 'dropbox-sdk-v2'
  gem 'platform-api'
  gem 'jbuilder', '~> 2.5'
  gem 'jquery-rails'
  gem 'kaminari'
  gem 'omniauth'
  gem 'omniauth-dropbox-oauth2', github: 'bamorim/omniauth-dropbox-oauth2'
  gem 'pg'
  gem 'puma', '~> 3.12'
  gem 'rails', '~> 5.0.7'
  gem 'sassc-rails'
  gem 'select2-rails'
  gem 'sidekiq'
  gem 'turbolinks'
  gem 'uglifier', '>= 1.3.0'
  gem 'jpeg_camera'
  gem 'wicked_pdf'
  #gem 'wkhtmltopdf-heroku'

  gem 'rubyzip', '>= 1.2.1'
  gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
  gem 'axlsx_rails'

  group :development, :test do
    gem 'dotenv-rails', require: 'dotenv/rails-now'
    gem 'pry-byebug', platform: :mri
    gem 'rspec'
    gem 'rubocop'
  end

  group :development do
    gem 'web-console', '>= 3.3.0'
    gem 'listen', '~> 3.0.5'
  end

  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
end
