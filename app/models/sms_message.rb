class SmsMessage < ApplicationRecord
  
  belongs_to :user
  belongs_to :customer
  belongs_to :company
  
end
