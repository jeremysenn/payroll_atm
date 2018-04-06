class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  # GET /payments
  # GET /payments.json
  def index
    @start_date = payment_params[:start_date] ||= Date.today.to_s
    @end_date = payment_params[:end_date] ||= Date.today.to_s
    
    payments = current_user.company.payments.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    @payments = payments.order("created_at DESC").page(params[:page]).per(20)
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)
    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.html { redirect_to :back, notice: 'Payment was successfully created.' }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment.payment_batch, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment_batch = @payment.payment_batch
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to @payment_batch, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.fetch(:payment, {}).permit(:PaymentAmt)
    end
    
end
