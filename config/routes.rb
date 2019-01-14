require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  get '/auth/:provider/callback' => 'auth#success'
  get '/auth/failure' => 'auth#failure'

  get '/auth/logout' => 'auth#logout', as: :signout

  resources :bank_accounts do
    collection { post :import }
  end
  resources :bank_lines
  resources :dividends do
    member { post :generate }
  end
  resources :invoices do
    member { post :generate }
  end
  resources :receipts do
    collection { get :gallery }
  end
  resources :reports, only: :index do
    collection do
      get :personal
    end
  end
  resources :manual_matches
  resources :wages
  resources :users, only: [:index, :update]
  root 'home#page'
end
