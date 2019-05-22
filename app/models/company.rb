class Company < ApplicationRecord
  belongs_to :user
  has_many :receipts
  has_many :invoices
  has_many :dividends
  has_many :bank_lines
  has_many :manual_matches

  scope :primary, -> { find_by(primary: true) }
end
