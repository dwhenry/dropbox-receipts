class Summary < ApplicationRecord
  belongs_to :last_receipt, class_name: 'Receipt', required: false
  belongs_to :last_manual, class_name: 'ManualMatch', required: false
  belongs_to :company
end
