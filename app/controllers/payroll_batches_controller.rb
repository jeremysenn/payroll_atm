class PayrollBatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payroll_batch, only: [:show, :edit, :update, :destroy]
#  load_and_authorize_resource
  
  # GET /payroll_batches
  # GET /payroll_batches.json
  def index
#    @start_date = payroll_batch_params[:start_date] ||= Date.today.to_s
#    @end_date = payroll_batch_params[:end_date] ||= Date.today.to_s
#    
#    payroll_batches = current_user.company.payroll_batches.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
#    @payroll_batches = payroll_batches.order("created_at DESC").page(params[:page]).per(20)

    @unprocessed_payroll_batches = current_user.company.payroll_batches.unprocessed.order("created_at DESC")
    @processed_payroll_batches = current_user.company.payroll_batches.processed.order("created_at DESC")
  end

  # GET /payroll_batches/1
  # GET /payroll_batches/1.json
  def show
  end

  # GET /payroll_batches/new
  def new
    @payroll_batch = PayrollBatch.new
  end

  # GET /payroll_batches/1/edit
  def edit
  end

  # POST /payroll_batches
  # POST /payroll_batches.json
  def create
    @payroll_batch = PayrollBatch.new(payroll_batch_params)
    csv_file = payroll_batch_params[:CSVFile]
    unless csv_file.blank?
      file_content = csv_file.read 
      @payroll_batch.CSVFile = file_content
    end
    respond_to do |format|
      if @payroll_batch.save
        format.html { redirect_to @payroll_batch, notice: 'PayrollBatch was successfully created.' }
        format.html { redirect_to :back, notice: 'PayrollBatch was successfully created.' }
      else
        format.html { render :new }
        format.json { render json: @payroll_batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payroll_batches/1
  # PATCH/PUT /payroll_batches/1.json
  def update
    respond_to do |format|
      if @payroll_batch.update(payroll_batch_params)
        format.html { redirect_to @payroll_batch, notice: 'PayrollBatch was successfully updated.' }
        format.json { render :show, status: :ok, location: @payroll_batch }
      else
        format.html { render :edit }
        format.json { render json: @payroll_batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payroll_batches/1
  # DELETE /payroll_batches/1.json
  def destroy
    @payroll_batch.destroy
    respond_to do |format|
      format.html { redirect_to payroll_batches_url, notice: 'PayrollBatch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payroll_batch
      @payroll_batch = PayrollBatch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payroll_batch_params
      params.fetch(:payroll_batch, {}).permit(:CompanyNbr, :CSVFile, :Processed)
    end
    
end
