class PayrollPayment< ActiveRecord::Base
  self.primary_key = 'PaymentID'
  self.table_name= 'PayrollPayments'
  
  establish_connection :ez_cash
  
  belongs_to :payroll_batch, :foreign_key => "BatchNbr"
  belongs_to :company, :foreign_key => "CompanyNbr"
  belongs_to :customer, :foreign_key => "CustomerID", optional: true
  belongs_to :ezcash_transaction, :class_name => 'Transaction', :foreign_key => "TranID", optional: true
  
  #############################
  #     Instance Methods      #
  #############################
  
  #############################
  #     Class Methods         #
  #############################
  
end