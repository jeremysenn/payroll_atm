class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  # GET /devices
  # GET /devices.json
  def index
    @devices = current_user.company.devices
  end
  
  def show
    @transactions = @device.transactions_last_30_days_with_amount
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end
end