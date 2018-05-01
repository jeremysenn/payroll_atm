class PaymentBatchCsvMappingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment_batch_csv_mapping, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  # GET /payment_batch_csv_mappings
  # GET /payment_batch_csv_mappings.json
  def index
    @payment_batch_csv_mappings = current_user.company.payment_batch_csv_mappings
    @remaining_payment_batch_csv_mappings = current_user.company.remaining_payment_batch_csv_mappings
  end

  # GET /payment_batch_csv_mappings/1
  # GET /payment_batch_csv_mappings/1.json
  def show
  end

  # GET /payment_batch_csv_mappings/new
  def new
    @payment_batch_csv_mapping = PaymentBatchCsvMapping.new
  end

  # GET /payment_batch_csv_mappings/1/edit
  def edit
  end

  # POST /payment_batch_csv_mappings
  # POST /payment_batch_csv_mappings.json
  def create
    @payment_batch_csv_mapping = PaymentBatchCsvMapping.new(payment_batch_csv_mapping_params)
    respond_to do |format|
      if @payment_batch_csv_mapping.save
#        format.html { redirect_to @payment_batch_csv_mapping, notice: 'PaymentBatchCsvMapping was successfully created.' }
        format.html { redirect_to payment_batch_csv_mappings_path, notice: 'PaymentBatchCsvMapping was successfully created.' }
        format.json { render :show, status: :ok, location: @payment_batch_csv_mapping }
      else
        format.html { render :new }
        format.json { render json: @payment_batch_csv_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_batch_csv_mappings/1
  # PATCH/PUT /payment_batch_csv_mappings/1.json
  def update
    respond_to do |format|
      if @payment_batch_csv_mapping.update(payment_batch_csv_mapping_params)
#        format.html { redirect_to @payment_batch_csv_mapping, notice: 'PaymentBatchCsvMapping was successfully updated.' }
        format.html { redirect_to payment_batch_csv_mappings_path, notice: 'PaymentBatchCsvMapping was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment_batch_csv_mapping }
      else
        format.html { render :edit }
        format.json { render json: @payment_batch_csv_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_batch_csv_mappings/1
  # DELETE /payment_batch_csv_mappings/1.json
  def destroy
    @payment_batch_csv_mapping.destroy
    respond_to do |format|
      format.html { redirect_to payment_batch_csv_mappings_url, notice: 'PaymentBatchCsvMapping was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_batch_csv_mapping
      @payment_batch_csv_mapping = PaymentBatchCsvMapping.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_batch_csv_mapping_params
      params.fetch(:payment_batch_csv_mapping, {}).permit(:column_name, :mapped_column_name, :company_id)
    end
    
end
