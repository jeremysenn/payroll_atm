class Group < ActiveRecord::Base
  self.primary_key = 'GroupID'
  self.table_name= 'Groups'
  
  establish_connection :ez_cash
  
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
end
