class AccountType < ActiveRecord::Base
  establish_connection :ez_cash
  self.primary_key = 'AccountTypeID'
  self.table_name= 'AccountTypes'
  
#  belongs_to :device, :foreign_key => 'dev_id'
  has_many :accounts
  
  #############################
  #     Instance Methods      #
  #############################
  
  #############################
  #     Class Methods      #
  #############################
  
end