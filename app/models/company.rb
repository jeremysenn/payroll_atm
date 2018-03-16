class Company < ActiveRecord::Base
  self.primary_key = 'CompanyNumber'
  self.table_name= 'Companies'
  
  establish_connection :ez_cash
  
  has_many :users
  has_many :customers, :foreign_key => "CompanyNumber" # AKA employees
  has_many :accounts, :foreign_key => "CompanyNumber" # This is all accounts that have this company ID
  has_many :sms_messages
  has_many :payment_batches, :foreign_key => "CompanyNbr"
  has_many :payments, :foreign_key => "CompanyNbr"
  
  ### Start Virtual Attributes ###
  def transaction_fee # Getter
    transaction_fee_cents.to_d / 100 if transaction_fee_cents
  end
  
  def transaction_fee=(dollars) # Setter
    self.transaction_fee_cents = dollars.to_d * 100 if dollars.present?
  end
  ### End Virtual Attributes ###
  
  #############################
  #     Instance Methods      #
  #############################
  
  def name
    self.CompanyName
  end
  
  def account
    Account.where(CompanyNumber: self.CompanyNumber, CustomerID: nil).last
  end
  
  def perform_one_sided_credit_transaction(amount)
    unless account.blank?
      transaction_id = account.ezcash_one_sided_credit_transaction_web_service_call(amount) 
      Rails.logger.debug "*************** Company One-sided EZcash transaction #{transaction_id}"
      return transaction_id
    end
  end
  
  #############################
  #     Class Methods      #
  #############################
  
end
