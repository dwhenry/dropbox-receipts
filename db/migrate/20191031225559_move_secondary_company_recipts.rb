class MoveSecondaryCompanyRecipts < ActiveRecord::Migration[5.0]
  def change
    Receipt.all.each do |receipt|
      next if receipt.company.primary?

      DropboxMover.perform_async(receipt.id)
    end
  end
end
