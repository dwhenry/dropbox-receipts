class User < ApplicationRecord
  def self.from_oauth(args)
    uid = args['info']['uid']
    name = args['info']['name']
    email = args['info']['email']
    token = args['credentials']['token']

    user = find_or_initialize_by(uid: uid, provider: 'dropbox')
    user.update!(name: name, email: email, token: token)
    user
  end
end
