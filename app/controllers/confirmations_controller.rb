class ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |resource|
      sign_in(resource)
#      flash[:alert] = "Please update your password."
    end
  end
end