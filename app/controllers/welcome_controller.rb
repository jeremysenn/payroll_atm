class WelcomeController < ApplicationController
#  before_action :authenticate_user!
  
  def index
    if current_user.employee?
      redirect_to current_user.customer
    end
  end
  
end
