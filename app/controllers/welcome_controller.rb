class WelcomeController < ApplicationController
#  before_action :authenticate_user!
  
  def index
    if user_signed_in? and current_user.employee?
      redirect_to current_user.customer
    end
  end
  
end
