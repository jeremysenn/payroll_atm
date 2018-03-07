class ErrorDesc < ActiveRecord::Base
  self.primary_key = 'error_code'
  self.table_name= 'error_desc'
  
  establish_connection :ez_cash
  
end