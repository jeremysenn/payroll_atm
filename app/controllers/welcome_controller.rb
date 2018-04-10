class WelcomeController < ApplicationController
#  before_action :authenticate_user!
  
  def index
    if user_signed_in?
      if current_user.payee?
        if not current_user.temporary_password.blank?
          flash[:error] = "You must update your password."
          redirect_to edit_registration_path(current_user)
        else
          redirect_to current_user.customer
        end
      end
      if current_user.admin?
        @devices = current_user.company.devices
        @processed_payment_batches = current_user.company.payment_batches.processed.order("created_at DESC").first(3)
      end
    end
  end
  
end
