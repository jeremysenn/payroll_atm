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
  has_one :company_act_default_min_bal, :foreign_key => "CompanyNumber"
  has_many :devices, :foreign_key => "CompanyNbr"
  has_many :transactions, :foreign_key => "DevCompanyNbr"
  has_many :payment_batch_csv_mappings
  
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
  
  def reference_number_mapping
    mapping = payment_batch_csv_mappings.find_by(mapped_column_name: "ReferenceNbr")
    unless mapping.blank?
      return mapping.column_name
    else
      return 'ReferenceNbr'
    end
  end
  
  def payee_number_mapping
    mapping = payment_batch_csv_mappings.find_by(mapped_column_name: "PayeeNbr")
    unless mapping.blank?
      return mapping.column_name
    else
      return 'PayeeNbr'
    end
  end
  
  def first_name_mapping
    mapping = payment_batch_csv_mappings.find_by(mapped_column_name: "FirstName")
    unless mapping.blank?
      return mapping.column_name
    else
      return 'FirstName'
    end
  end
  
  def last_name_mapping
    mapping = payment_batch_csv_mappings.find_by(mapped_column_name: "LastName")
    unless mapping.blank?
      return mapping.column_name
    else
      return 'LastName'
    end
  end
  
  def payment_amount_mapping
    mapping = payment_batch_csv_mappings.find_by(mapped_column_name: "PaymentAmt")
    unless mapping.blank?
      return mapping.column_name
    else
      return 'PaymentAmt'
    end
  end
  
  def remaining_payment_batch_csv_mappings
    mapped_column_names = ["ReferenceNbr", "PayeeNbr", "FirstName", "LastName", "PaymentAmt"]
    custom_mappings = payment_batch_csv_mappings.map(&:mapped_column_name)
    return mapped_column_names - custom_mappings
  end
  
  #############################
  #     Class Methods      #
  #############################
  
end
