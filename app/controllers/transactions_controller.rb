class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :edit, :update, :destroy, :reverse]
  load_and_authorize_resource
  
  helper_method :transactions_sort_column, :transactions_sort_direction

  # GET /transactions
  # GET /transactions.json
  def index
    @type = params[:type] ||= 'All'
#    @start_date = transaction_params[:start_date] ||= Date.today.to_s
#    @end_date = transaction_params[:end_date] ||= Date.today.to_s
    @start_date = params[:start_date] ||= Date.today.last_week.to_s
    @end_date = params[:end_date] ||= Date.today.to_s
    @transaction_id_or_receipt_number = params[:transaction_id]
    if @transaction_id_or_receipt_number.blank?
      if @type == 'Withdrawal'
        @all_transactions = current_user.company.transactions.withdrawals.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
      elsif @type == 'Transfer'
        @all_transactions = current_user.company.transactions.transfers.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
      elsif @type == 'Balance'
        @all_transactions = current_user.company.transactions.one_sided_credits.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
      elsif @type == 'Fee'
        @all_transactions = current_user.company.transactions.fees.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
      elsif @type == 'Check'
        @all_transactions = current_user.company.transactions.checks.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
      else
#        @all_transactions = current_user.company.transactions.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
        @all_transactions = current_user.company.transactions.not_fees.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
      end
    else
      @start_date = nil
      @end_date = nil
#      transactions = current_user.company.transactions.where(tranID: params[:transaction_id])
      @all_transactions = current_user.company.transactions.where(tranID: @transaction_id_or_receipt_number).or(current_user.company.transactions.where(receipt_nbr: @transaction_id_or_receipt_number))
    end
    
    respond_to do |format|
      format.html {
        @transactions_total = 0
        @transactions_fee_total = 0
        @transactions_count = @all_transactions.count
        @all_transactions.each do |transaction|
          @transactions_total = @transactions_total + transaction.amt_auth unless transaction.amt_auth.blank?
          @transactions_fee_total = @transactions_fee_total + transaction.ChpFee unless transaction.ChpFee.blank? or transaction.ChpFee.zero?
        end
        @transactions = @all_transactions.order("#{transactions_sort_column} #{transactions_sort_direction}").page(params[:transactions_page]).per(20)
      }
      format.csv { 
        @transactions = @all_transactions
        send_data @transactions.to_csv, filename: "#{@type}_transactions-#{@start_date}-#{@end_date}.csv" 
        }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @reversal_transaction = @transaction.reversal_transaction
    @original_transaction = @transaction.original_transaction
    @from_customer = @transaction.from_account_customer
    @to_customer = @transaction.to_account_customer
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
  
  def reverse
    if @transaction.reverse
      redirect_back fallback_location: root_path, notice: 'Transaction was successfully reversed.'
    else
      redirect_back fallback_location: root_path, alert: 'There was a problem reversing the transaction.'
    end
  end
  
  def quick_pay
    @amount = params[:amount]
    @receipt_number = params[:receipt_number]
    @note = params[:note]
    @device_id = params[:device_id]
    unless params[:customer_id].blank?
      @customer = Customer.find(params[:customer_id])
    end
    if @customer.blank?
      @customer = Customer.create(CompanyNumber: current_user.company_id, LangID: 1, Active: 1, GroupID: 15)
      @account = Account.create(CustomerID: @customer.id, CompanyNumber: current_user.company_id, ActNbr: @receipt_number, Balance: 0, MinBalance: 0, ActTypeID: 6)
    end
    if params[:pay_and_text]
      response = @customer.one_time_payment(@amount, @note, @receipt_number)
    else
      response = @customer.one_time_payment_with_no_text_message(@amount, @note, @receipt_number)
    end
    response_code = response[:return]
    unless response_code.to_i > 0
      transaction_id = response[:tran_id]
    else
      error_code = response_code
    end
    unless transaction_id.blank?
#      redirect_back fallback_location: root_path, notice: 'Quick Pay submitted.'
#      redirect_to barcode_customer_path(@customer), notice: 'Quick Pay submitted.'
      redirect_to root_path(customer_id: @customer.id), notice: 'Quick Pay submitted.'
    else
      redirect_back fallback_location: root_path, alert: "There was a problem creating the Quick Pay. Error code: #{error_code}"
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
