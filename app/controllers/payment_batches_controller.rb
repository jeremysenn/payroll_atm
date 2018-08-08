class PaymentBatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment_batch, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  # GET /payment_batches
  # GET /payment_batches.json
  def index
#    @start_date = payment_batch_params[:start_date] ||= Date.today.to_s
#    @end_date = payment_batch_params[:end_date] ||= Date.today.to_s
#    
#    payment_batches = current_user.company.payment_batches.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
#    @payment_batches = payment_batches.order("created_at DESC").page(params[:page]).per(20)

    @unprocessed_cash_payment_batches = current_user.company.payment_batches.cash.unprocessed.order("created_at DESC")
    @processed_cash_payment_batches = current_user.company.payment_batches.cash.processed.order("created_at DESC")
    @unprocessed_check_payment_batches = current_user.company.payment_batches.check.unprocessed.order("created_at DESC")
    @processed_check_payment_batches = current_user.company.payment_batches.check.processed.order("created_at DESC")
  end

  # GET /payment_batches/1
  # GET /payment_batches/1.json
  def show
    @payment_batch_csv_mappings = current_user.company.payment_batch_csv_mappings
  end

  # GET /payment_batches/new
  def new
    @payment_batch = PaymentBatch.new
  end

  # GET /payment_batches/1/edit
  def edit
  end

  # POST /payment_batches
  # POST /payment_batches.json
  def create
    @payment_batch = PaymentBatch.new(payment_batch_params)
    csv_file = payment_batch_params[:CSVFile]
    unless csv_file.blank?
      file_content = csv_file.read 
      @payment_batch.CSVFile = file_content
    end
    respond_to do |format|
      if @payment_batch.save
        format.html { redirect_to @payment_batch, notice: 'PaymentBatch was successfully created.' }
        format.json { render :show, status: :ok, location: @payment_batch }
      else
        format.html { render :new }
        format.json { render json: @payment_batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_batches/1
  # PATCH/PUT /payment_batches/1.json
  def update
    respond_to do |format|
      if @payment_batch.update(payment_batch_params)
        format.html { redirect_to @payment_batch, notice: 'PaymentBatch was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment_batch }
      else
        format.html { render :edit }
        format.json { render json: @payment_batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_batches/1
  # DELETE /payment_batches/1.json
  def destroy
    @payment_batch.destroy
    respond_to do |format|
      format.html { redirect_to payment_batches_url, notice: 'PaymentBatch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def csv_template
    respond_to do |format|
      format.csv { 
        send_data current_user.company.payment_batch_csv_template, filename: "payment_batch_csv_template_#{Time.now}.csv" 
        }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_batch
      @payment_batch = PaymentBatch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_batch_params
      params.fetch(:payment_batch, {}).permit(:CompanyNbr, :CSVFile, :Processed, :IsCheckBatch)
    end
    
end
