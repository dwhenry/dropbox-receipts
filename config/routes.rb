Rails.application.routes.draw do
  get '/auth/:provider/callback' => 'auth#success'
  get '/auth/failure' => 'auth#failure'

  get '/auth/logout' => 'auth#logout', as: :signout

  resources :receipts

  root 'receipts#new'
end
