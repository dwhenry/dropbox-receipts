class RenameCompanyToCompanyAnme < ActiveRecord::Migration[5.0]
  def change
    rename_column :receipts, :company, :company_name
    Company.all.each do |company|
      company.update!(name: company.invoices.last&.company_name)
    end
  end
end
