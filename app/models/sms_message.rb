class SmsMessage < ApplicationRecord
  
  belongs_to :user, optional: true
  belongs_to :customer
  belongs_to :company
  
end
