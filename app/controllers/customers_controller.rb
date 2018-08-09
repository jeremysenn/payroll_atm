class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :one_time_payment, :send_barcode_link_sms_message]
  load_and_authorize_resource
  skip_load_resource only: :barcode
  
  # GET /customers
  # GET /customers.json
  def index
    unless params[:q].blank?
      @query_string = "%#{params[:q]}%"
      @all_customers = current_user.company.customers.where("NameF like ? OR NameL like ? OR PhoneMobile like ?", @query_string, @query_string, @query_string) #.order("customer.NameL")
    else
      @all_customers = current_user.company.customers.payees
    end
    @customers = @all_customers.page(params[:page]).per(20)
  end
  
  # GET /customers/1
  # GET /customers/1.json
  def show
    @withdrawal_transactions = Kaminari.paginate_array(@customer.withdrawals).page(params[:withdrawals]).per(10)
    @payment_transactions =  Kaminari.paginate_array(@customer.successful_payments).page(params[:payments]).per(10)
    @check_transactions =  Kaminari.paginate_array(@customer.cashed_checks).page(params[:checks]).per(10)
    @sms_messages = @customer.sms_messages.order("created_at DESC").page(params[:messages]).per(10)
    @account = @customer.accounts.first
#    @base64_barcode_string = @customer.barcode_png
#    @barcode_access_string = @customer.barcode_access_string
    if @customer.user.blank?
#      @temporary_password = Devise.friendly_token.first(10)
#      @temporary_password = SecureRandom.hex.first(6)
      @temporary_password = SecureRandom.random_number(10**6).to_s
    end
  end
  
  # GET /customers/new
  def new
    @customer = Customer.new
    @customer.accounts.build
  end
  
  # GET /customers/1/edit
  def edit
  end
  
  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def one_time_payment
    amount = params[:amount].to_f.abs unless params[:amount].blank?
    note = params[:note]
    receipt_number = params[:receipt_number]
    response = @customer.one_time_payment(amount, note, receipt_number)
#    transaction_id = @customer.one_time_payment(amount, note)
    response_code = response[:return]
    unless response_code.to_i > 0
      transaction_id = response[:tran_id]
      @customer.generate_barcode_access_string
    else
      error_code = response_code
    end
    Rails.logger.debug "*********************************One time payment transaction ID: #{transaction_id}"
    unless transaction_id.blank?
      redirect_back fallback_location: @customer, notice: 'One time payment submitted.'
    else
      redirect_back fallback_location: @customer, alert: "There was a problem creating the one time payment. Error code: #{error_code}"
    end
  end
  
  def send_sms_message
    @message_body = params[:message_body]
    unless params[:customer_ids].blank?
      params[:customer_ids].each do |customer_id|
        customer = Customer.where(CustomerID: customer_id).first
        customer.send_sms_message(@message_body, current_user.id) unless customer.blank?
      end
      redirect_back fallback_location: customers_path, notice: 'Text message sent.'
    else
      redirect_back fallback_location: customers_path, alert: 'You must select at least one customer to text message.'
    end
  end
  
  def barcode
    @customer = Customer.find_by(barcode_access_string: params[:id]) # ID is random and unique urlsafe_base64 string
#    if current_user.customer == @customer
#      unless @customer.blank?
#        @base64_barcode_string = Transaction.ezcash_get_barcode_png_web_service_call(@customer.CustomerID, current_user.company_id, 5)
#      else
#        redirect_to root_path, alert: 'There was a problem getting barcode.'
#      end
#    else
#      redirect_back fallback_location: root_path, alert: 'Only the payee has access to that page.'
#    end
    unless @customer.blank?
      @base64_barcode_string = Transaction.ezcash_get_barcode_png_web_service_call(@customer.CustomerID, current_user.company_id, 5)
    else
      redirect_to root_path, alert: 'There was a problem getting barcode.'
    end
  end
  
  def send_barcode_link_sms_message
    unless @customer.barcode_access_string.blank?
      @customer.send_barcode_link_sms_message
      redirect_back fallback_location: @customer, notice: 'Text message sent.'
    else
      redirect_back fallback_location: @customer, alert: 'There was a problem with barcode.'
    end
  end
  
  def send_barcode_sms_message
    @customer.send_barcode_sms_message
    redirect_back fallback_location: @customer, notice: 'Text message sent.'
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:ParentCustID, :CompanyNumber, :Active, :GroupID, :NameF, :NameL, :NameS, :PhoneMobile, :Email, 
        :LangID, :Registration_Source, :Registration_Source_ext, :create_payee_user_flag,
        accounts_attributes:[:CompanyNumber, :Balance, :MinBalance, :Active, :CustomerID, :ActNbr, :ActTypeID, :BankActNbr, :RoutingNbr, :_destroy,:id])
    end
  
end
