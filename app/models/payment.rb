class Payment< ActiveRecord::Base
  self.primary_key = 'PaymentID'
  self.table_name= 'Payments'
  
  establish_connection :ez_cash
  
  belongs_to :payment_batch, :foreign_key => "BatchNbr"
  belongs_to :company, :foreign_key => "CompanyNbr"
  belongs_to :customer, :foreign_key => "CustomerID", optional: true
  belongs_to :ezcash_transaction, :class_name => 'Transaction', :foreign_key => "TranID", optional: true
  
  scope :processed, -> { where(Processed: 1) }
  
  #############################
  #     Instance Methods      #
  #############################
  
  def processed?
    self.Processed?
  end
  
  def send_customer_text_message_payment_link
    phone = customer.phone
    barcode_access_string = customer.barcode_access_string
    unless phone.blank? or barcode_access_string.blank?
#      SendSmsWorker.perform_async(cell_phone_number, id, self.CustomerID, self.ClubCompanyNbr, message_body)
      payment_link = "#{Rails.application.routes.default_url_options[:host]}/customers/#{barcode_access_string}/barcode"
      message = "You've just been paid by #{customer.company.name}! Get your cash from the PaymentATM by clicking this link: #{payment_link}"
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      client.call(:send_sms, message: { Phone: phone, Msg: "#{message}"})
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end