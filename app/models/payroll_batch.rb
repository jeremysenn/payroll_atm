class PayrollBatch < ActiveRecord::Base
  self.primary_key = 'BatchNbr'
  self.table_name= 'PayrollBatches'
  establish_connection :ez_cash
  
  require 'csv'
  
  scope :processed, -> { where(Processed: 1) }
  scope :unprocessed, -> { where(Processed: [0, nil]) }
  
  has_many :payroll_payments, :foreign_key => "BatchNbr"
  belongs_to :company, :foreign_key => "CompanyNbr"
  
  validates :CSVFile, presence: true
  
  after_commit :create_payroll_payments_from_csv, on: [:create]
  after_update :process
    
  #############################
  #     Instance Methods      #
  #############################
  
  def processed?
    self.Processed?
  end
  
  def create_payroll_payments_from_csv
    CSV.parse(self.CSVFile, { :headers => true }) do |row| 
      customer = Customer.find_by(CompanyNumber: self.CompanyNbr, Registration_Source: row['EmployeeNbr'])
      if customer.blank?
        customer = Customer.find_by(CompanyNumber: self.CompanyNbr, NameF: row['EmployeeFirstName'], NameL: row['EmployeeLastName'])
      end
      PayrollPayment.create(CompanyNbr: self.CompanyNbr, BatchNbr: self.BatchNbr, CustomerID: customer.blank? ? nil : customer.id, EmployeeNbr: row['EmployeeNbr'], NetPaycheckAmt: row['NetPaycheckAmt'])
    end
  end
  
  def process
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    begin
      response = client.call(:process_payroll_batch, message: { PayrollBatchNbr: self.BatchNbr})
      Rails.logger.debug "************** payroll_batch.process response body: #{response.body}"
      if response.success?
        unless response.body[:process_payroll_batch_response].blank?
          self.processed_status = response.body[:process_payroll_batch_response][:return]
          return response.body[:process_payroll_batch_response][:return]
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