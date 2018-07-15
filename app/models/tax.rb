class Tax < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { where(source_type: 'Tax') }, class_name: "BankLine", foreign_key: :source_id
end
