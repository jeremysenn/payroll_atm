class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  helper_method :transactions_sort_column, :transactions_sort_direction

  # GET /transactions
  # GET /transactions.json
  def index
    @type = params[:type] ||= 'Withdrawal'
    @start_date = transaction_params[:start_date] ||= Date.today.to_s
    @end_date = transaction_params[:end_date] ||= Date.today.to_s
    
    if @type == 'Withdrawal'
      transactions = current_user.company.transactions.withdrawals.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    elsif @type == 'Transfer'
      transactions = current_user.company.transactions.transfers.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    elsif @type == 'Balance'
      transactions = current_user.company.transactions.one_sided_credits.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    elsif @type == 'Fee'
      transactions = current_user.company.transactions.fees.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    else
      transactions = current_user.company.transactions.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
    end
    @transactions_total = 0
    @transactions_count = transactions.count
    transactions.each do |transaction|
      @transactions_total = @transactions_total + transaction.amt_auth unless transaction.amt_auth.blank?
    end
    @transactions = transactions.order("#{transactions_sort_column} #{transactions_sort_direction}").page(params[:page]).per(20)
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
#        format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
#        format.html { redirect_to :back, notice: 'Transaction was successfully created.' }
        format.html { redirect_back fallback_location: root_path, notice: 'Transaction was successfully created.' }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url, notice: 'Transaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.fetch(:transaction, {}).permit(:start_date, :end_date)
    end
    
    ### Secure the transactions sort direction ###
    def transactions_sort_direction
      %w[asc desc].include?(params[:transactions_direction]) ?  params[:transactions_direction] : "desc"
    end

    ### Secure the transactions sort column name ###
    def transactions_sort_column
      ["tranID", "dev_id", "date_time", "error_code", "tran_status", "amt_auth", "ChpFee"].include?(params[:transactions_column]) ? params[:transactions_column] : "tranID"
    end
end
