class PayrollPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payroll_payment, only: [:show, :edit, :update, :destroy]
#  load_and_authorize_resource
  
  # GET /payroll_payments
  # GET /payroll_payments.json
  def index
    @start_date = payroll_payment_params[:start_date] ||= Date.today.to_s
    @end_date = payroll_payment_params[:end_date] ||= Date.today.to_s
    
    payroll_payments = current_user.company.payroll_payments.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    @payroll_payments = payroll_payments.order("created_at DESC").page(params[:page]).per(20)
  end

  # GET /payroll_payments/1
  # GET /payroll_payments/1.json
  def show
  end

  # GET /payroll_payments/new
  def new
    @payroll_payment = PayrollPayment.new
  end

  # GET /payroll_payments/1/edit
  def edit
  end

  # POST /payroll_payments
  # POST /payroll_payments.json
  def create
    @payroll_payment = PayrollPayment.new(payroll_payment_params)
    respond_to do |format|
      if @payroll_payment.save
        format.html { redirect_to @payroll_payment, notice: 'PayrollPayment was successfully created.' }
        format.html { redirect_to :back, notice: 'PayrollPayment was successfully created.' }
      else
        format.html { render :new }
        format.json { render json: @payroll_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payroll_payments/1
  # PATCH/PUT /payroll_payments/1.json
  def update
    respond_to do |format|
      if @payroll_payment.update(payroll_payment_params)
        format.html { redirect_to @payroll_payment.payroll_batch, notice: 'PayrollPayment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payroll_payment }
      else
        format.html { render :edit }
        format.json { render json: @payroll_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payroll_payments/1
  # DELETE /payroll_payments/1.json
  def destroy
    @payroll_batch = @payroll_payment.payroll_batch
    @payroll_payment.destroy
    respond_to do |format|
      format.html { redirect_to @payroll_batch, notice: 'PayrollPayment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payroll_payment
      @payroll_payment = PayrollPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payroll_payment_params
      params.fetch(:payroll_payment, {}).permit(:NetPaycheckAmt)
    end
    
end
