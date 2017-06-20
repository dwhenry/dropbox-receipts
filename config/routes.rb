require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  get '/auth/:provider/callback' => 'auth#success'
  get '/auth/failure' => 'auth#failure'

  get '/auth/logout' => 'auth#logout', as: :signout

  resources :receipts do
    collection { get :gallery }
  end
  resources :invoices

  root 'receipts#new'
end
