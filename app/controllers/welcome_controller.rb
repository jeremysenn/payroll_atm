class WelcomeController < ApplicationController
#  before_action :authenticate_user!
  
  def index
    if user_signed_in?
      if current_user.employee?
        redirect_to current_user.customer
      end
      if current_user.admin?
        @processed_payment_batches = current_user.company.payment_batches.processed.order("created_at DESC").first(3)
      end
    end
  end
  
end
