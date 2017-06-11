source 'https://rubygems.org'
ruby "2.3.3"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

source 'https://rubygems.org' do

  gem 'bootstrap', '~> 4.0.0.alpha5'
  gem 'coffee-rails', '~> 4.2'
  gem 'dropbox-sdk'
  gem 'jbuilder', '~> 2.5'
  gem 'jquery-rails'
  gem 'omniauth'
  gem 'omniauth-dropbox-oauth2'
  gem 'pg'
  gem 'puma', '~> 3.0'
  gem 'rails', '~> 5.0.2'
  gem 'sass-rails', '~> 5.0'
  gem 'sidekiq'
  gem 'turbolinks', '~> 5'
  gem 'uglifier', '>= 1.3.0'
  gem 'jpeg_camera'

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
