class MyDropboxClient < Dropbox::Client
  # remove token validation as it is out of date....
  def initialize(access_token)
    @access_token = access_token
  end
end
