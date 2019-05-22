class User < ApplicationRecord
  has_many :companies
  # has_many :receipts, through: :companies
  # has_many :invoices, through: :companies
  # has_many :dividends, through: :companies
  # has_many :bank_lines, through: :companies
  # has_many :manual_matches, through: :companies

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
