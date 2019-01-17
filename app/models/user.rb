class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :registerable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable #, :timeoutable
       
  ROLES = %w[admin basic payee].freeze
       
  belongs_to :company
  belongs_to :customer, optional: true
  has_many :sms_messages
  
  serialize :device_ids, Array
  
  scope :admin, -> { where(role: "admin") }
  scope :basic, -> { where(role: "basic") }
  scope :payee, -> { where(role: "payee") }
  
  before_create :search_for_payee_match
  after_create :send_confirmation_sms_message
  after_update :send_new_phone_number_confirmation_sms_message, if: :phone_changed?
  
  validates :phone, uniqueness: true, presence: true  
    
  #############################
  #     Instance Methods      #
  #############################
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def admin?
    role == "admin"
  end
  
  def basic?
    role == "basic"
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
    else
      if self.role.blank?
        self.role = "basic"
      end
    end
  end
  
  def send_confirmation_sms_message
    unless phone.blank?
#      SendCaddySmsWorker.perform_async(cell_phone_number, id, self.CustomerID, self.ClubCompanyNbr, message_body)
      confirmation_link = "#{Rails.application.routes.default_url_options[:host]}/users/confirmation?confirmation_token=#{confirmation_token}"
      unless temporary_password.blank?
        message = "Confirm your PaymentATM account by clicking the link below. Your temporary password is: #{temporary_password} #{confirmation_link}"
      else
        message = "Confirm your PaymentATM account by clicking the link below. #{confirmation_link}"
      end
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      client.call(:send_sms, message: { Phone: phone, Msg: "#{message}"})
#      SmsMessage.create(to: phone, company_id: company_id, body: "#{message}")
    end
  end
  
  def send_new_phone_number_confirmation_sms_message
    unless phone.blank?
      confirmation_link = "#{Rails.application.routes.default_url_options[:host]}/users/confirmation?confirmation_token=#{confirmation_token}"
      message = "Confirm the change to your PaymentATM account by clicking the link below.  #{confirmation_link}"
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      client.call(:send_sms, message: { Phone: phone, Msg: "#{message}"})
      self.confirmed_at = nil
      self.save
    end
  end
  
  def phone_changed?
    saved_change_to_phone?
  end
  
  def devices
#    company.devices
    if admin?
      company.devices
    elsif basic?
      company.devices.where(dev_id: device_ids)
    end
  end
  
end
