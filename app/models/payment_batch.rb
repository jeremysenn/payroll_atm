class PaymentBatch < ActiveRecord::Base
  self.primary_key = 'BatchNbr'
  self.table_name= 'PaymentBatches'
  establish_connection :ez_cash
  
  require 'csv'
  
  scope :processed, -> { where(Processed: 1) }
  scope :unprocessed, -> { where(Processed: [0, nil]) }
  
  has_many :payments, :foreign_key => "BatchNbr"
  belongs_to :company, :foreign_key => "CompanyNbr"
  
  validates :CSVFile, presence: true
  
  after_commit :create_payments_from_csv, on: [:create]
  before_update :process
    
  #############################
  #     Instance Methods      #
  #############################
  
  def processed?
    self.Processed?
  end
  
  def create_payments_from_csv
    CSV.parse(self.CSVFile, { :headers => true }) do |row| 
      customer = Customer.find_by(CompanyNumber: self.CompanyNbr, Registration_Source: row['PayeeNbr'])
      Payment.create(CompanyNbr: self.CompanyNbr, BatchNbr: self.BatchNbr, ReferenceNbr:  row['ReferenceNbr'], CustomerID: customer.blank? ? nil : customer.id, PayeeNbr: row['PayeeNbr'], PaymentAmt: row['PaymentAmt'])
    end
  end
  
  def process
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    begin
      response = client.call(:process_payment_batch, message: { PayrollBatchNbr: self.BatchNbr})
      if response.success?
        Rails.logger.debug "************** payment_batch.process response body: #{response.body}"
        unless response.body[:process_payment_batch_response].blank?
          self.processed_status = response.body[:process_payment_batch_response][:return]
          return response.body[:process_payment_batch_response][:return]
        end
      end
    rescue Savon::SOAPFault => error
      raise ActiveRecord::Rollback
      Rails.logger.debug error.http.code
      return error.http.code
    rescue Savon::HTTPError => error
      raise ActiveRecord::Rollback
      Rails.logger.debug error.http.code
      return error.http.code
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end