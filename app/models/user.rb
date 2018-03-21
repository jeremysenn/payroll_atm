class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :registerable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable
       
  ROLES = %w[admin payee].freeze
       
  belongs_to :company
  belongs_to :customer, optional: true
  has_many :sms_messages
  
  before_create :search_for_payee_match
  after_create :send_confirmation_sms_message
  
  #############################
  #     Instance Methods      #
  #############################
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def admin?
    role == "admin"
  end
  
  def payee?
    role == "payee"
  end
  
  def search_for_payee_match
    payee = Customer.find_by(PhoneMobile: phone)
    unless payee.blank?
      self.customer_id = payee.id
      self.role = "payee"
      self.company_id = payee.company_id
    end
  end
  
  def send_confirmation_sms_message
    unless phone.blank?
#      SendCaddySmsWorker.perform_async(cell_phone_number, id, self.CustomerID, self.ClubCompanyNbr, message_body)
      confirmation_link = "#{Rails.application.routes.default_url_options[:host]}/users/confirmation?confirmation_token=#{confirmation_token}"
      message = "Confirm your PaymentATM account by clicking the link below. Your temporary password is: #{temporary_password} #{confirmation_link}"
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      client.call(:send_sms, message: { Phone: phone, Msg: "#{message}"})
      SmsMessage.create(to: phone, company_id: company_id, body: "#{message}")
    end
  end
  
end
