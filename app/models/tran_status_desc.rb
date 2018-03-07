class TranStatusDesc < ActiveRecord::Base
  self.primary_key = 'tran_status'
  self.table_name= 'tran_status_desc'
  
  establish_connection :ez_cash
  
end