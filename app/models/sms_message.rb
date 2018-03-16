class SmsMessage < ApplicationRecord
  
  belongs_to :user, optional: true
  belongs_to :customer, optional: true
  belongs_to :company
  
end
