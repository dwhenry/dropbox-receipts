Rails.application.routes.draw do
  post '/auth/:provider/callback' => 'auth#success'
  get '/auth/failure' => 'auth#failure'
end
