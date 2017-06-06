Rails.application.config.middleware.use OmniAuth::Builder do
  provider :dropbox_oauth2, ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET']
end
