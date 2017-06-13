require 'dropbox_sdk'

class DropboxSaver
  include Sidekiq::Worker

  def perform(data, receipt_id)
    receipt = Receipt.find_by(id: receipt_id) || Receipt.first
    path = [
      'receipts',
      receipt.created_at.strftime('%Y-%m'),
      name = [
        receipt.created_at.strftime('%d %b-%H:%M:%S'),
        receipt.code,
        receipt.id,
        'jpeg'
      ].compact.join('.')
    ].compact.join('/')

    client = DropboxClient.new(receipt.user.token)

    file = Base64.decode64(data)
    client.put_file(path, file) # should hopefully raise an error if it fails..

    receipt.update!(image: path)
  end
end
