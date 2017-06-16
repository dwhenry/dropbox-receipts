require 'dropbox_sdk'

class DropboxMover
  include Sidekiq::Worker

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    new_path = receipt.build_path

    return if new_path == receipt.path

    client = DropboxClient.new(receipt.user.token)

    begin
      client.file_move(receipt.path, new_path) # should hopefully raise an error if it fails..
    rescue DropboxError => e
      if e.http_response.is_a?(Net::HTTPNotFound)
        # file could not be found to move so create a new copy of it on the server
        DropboxSaver.perform_async(receipt_id)
      else
        raise
      end
    end


    receipt.update!(path: new_path)
  end
end
