class PaymentBatchCsvMapping < ActiveRecord::Base
  self.table_name= 'PaymentBatchCSVMappings'
  establish_connection :ez_cash
  
  belongs_to :company
  
  validates :column_name, presence: true
  validates :mapped_column_name, presence: true
  validates_uniqueness_of :mapped_column_name, scope: :company_id
  
  #############################
  #     Instance Methods      #
  #############################
  
  #############################
  #     Class Methods         #
  #############################
  
end