class AccountType < ActiveRecord::Base
  establish_connection :ez_cash
  self.primary_key = 'AccountTypeID'
  self.table_name= 'AccountTypes'
  
  has_many :accounts
  
  #############################
  #     Instance Methods      #
  #############################
  
  #############################
  #     Class Methods      #
  #############################
  
end