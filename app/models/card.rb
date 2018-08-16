class Card < ActiveRecord::Base
  establish_connection :ez_cash
#  self.primary_key = 'card_nbr'
  self.primary_key = 'card_seq'
  
  belongs_to :device, :foreign_key => 'dev_id'
  belongs_to :company
end