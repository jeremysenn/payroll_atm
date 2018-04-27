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
    @transactions = @device.transactions.where(DevCompanyNbr: current_user.company_id, date_time: Date.today.beginning_of_day.last_month..Date.today.end_of_day).order("date_time DESC")
    @dev_statuses = @device.dev_statuses.where(date_time: Date.today.beginning_of_day.last_week..Date.today.end_of_day).order("date_time DESC")
    @bill_counts = @device.bill_counts
    @denoms = @device.denoms
#    @bill_hists = @device.bill_hists
    @bill_hists = @device.bill_hists.select(:cut_dt).distinct.order("cut_dt DESC").first(5)
    ### WSDL Pieces ###
#    @wsdl_device = Device.find_by_id(params[:id])
#    @wsdl_transactions = Transaction.wsdl_find_last_20_by_device_id(params[:id])
#    @wsdl_dev_statuses = DevStatus.wsdl_find_last_20_by_device_id(params[:id])
#    @wsdl_bill_hists = BillHist.wsdl_find_last_5_distinct_by_device_id(params[:id])
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end
end