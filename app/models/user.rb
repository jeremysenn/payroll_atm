class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
       
  ROLES = %w[admin employee].freeze
       
  belongs_to :company
  belongs_to :customer, optional: true
  
  before_create :search_for_employee_match
       
  #############################
  #     Instance Methods      #
  #############################
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def admin?
    role == "admin"
  end
  
  def employee?
    role == "employee"
  end
  
  def search_for_employee_match
    employee = Customer.find_by(Email: email)
    unless employee.blank?
      self.customer_id = employee.id
      self.role = "employee"
      self.company_id = employee.CompanyNumber
    end
  end
  
end
