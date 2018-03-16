class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
       
  ROLES = %w[admin payee].freeze
       
  belongs_to :company
  belongs_to :customer, optional: true
  has_many :sms_messages
  
  before_create :search_for_payee_match
       
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
    payee = Customer.find_by(Email: email)
    unless payee.blank?
      self.customer_id = payee.id
      self.role = "payee"
      self.company_id = payee.CompanyNumber
    end
  end
  
end
