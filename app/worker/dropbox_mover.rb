require 'dropbox'

class DropboxMover
  include Sidekiq::Worker

  def perform(receipt_id)
    receipt = Receipt.find(receipt_id)
    old_path = receipt.path
    new_path = receipt.build_path

    return if new_path == old_path

    if old_path.nil?
      DropboxSaver.perform_async(receipt_id)
      return
    end

    client = MyDropboxClient.new(receipt.company.user.token)

    begin
      client.move(old_path, new_path) # should hopefully raise an error if it fails..
    rescue Dropbox::ApiError => e
      raise unless e.message =~ /not_found/

      # file could not be found to move so create a new copy of it on the server
      DropboxSaver.perform_async(receipt_id)
    end

    receipt.update!(path: new_path)
  end
end
