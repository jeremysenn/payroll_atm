class Company < ActiveRecord::Base
  self.primary_key = 'CompanyNumber'
  self.table_name= 'Companies'
  
  establish_connection :ez_cash
  
  has_many :users
  has_many :customers, :foreign_key => "CompanyNumber" # AKA employees
  
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
  
  
  #############################
  #     Class Methods      #
  #############################
  
end
