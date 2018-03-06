class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
       
  belongs_to :company
  belongs_to :customer, optional: true
       
  #############################
  #     Instance Methods      #
  #############################
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
end
