require 'dropbox'

class DropboxSaver
  include Sidekiq::Worker

  def perform(receipt_id)
    receipt = Receipt.find_by(id: receipt_id) || Receipt.first
    path = receipt.build_path

    client = Dropbox::Client.new(receipt.user.token)

    file = Base64.decode64(receipt.image.split(',', 2).last.gsub(' ', '+'))
    client.upload(path, file) # should hopefully raise an error if it fails..

    receipt.update!(path: path)
  rescue => e
    require 'pry'
    binding.pry
  end
end
