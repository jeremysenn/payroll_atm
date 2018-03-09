class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :one_time_payment]
  
  # GET /customers
  # GET /customers.json
  def index
    @employees = current_user.company.customers.employees.last(20)
  end
  
  # GET /customers/1
  # GET /customers/1.json
  def show
    @withdrawal_transactions = @employee.withdrawals
    @payment_transactions = @employee.payments
    @sms_messages = @employee.sms_messages
    @account = @employee.accounts.first
    @base64_barcode_string = @employee.barcode_png
  end
  
  # GET /customers/new
  def new
    @employee = Customer.new
#    @employee.accounts.build
  end
  
  # GET /customers/1/edit
  def edit
  end
  
  # POST /customers
  # POST /customers.json
  def create
    @employee = Customer.new(customer_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @employee.update(customer_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Employee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def one_time_payment
    amount = params[:amount].to_f.abs unless params[:amount].blank?
    note = params[:note]
    transaction_id = @employee.one_time_payment(amount, note)
    Rails.logger.debug "*********************************One time payment transaction ID: #{transaction_id}"
    unless transaction_id.blank?
      redirect_back fallback_location: @employee, notice: 'One time payment submitted.'
    else
      redirect_back fallback_location: @employee, alert: 'There was a problem creating the one time payment.'
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
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:ParentCustID, :CompanyNumber, :Active, :GroupID, :NameF, :NameL, :NameS, :PhoneMobile, :Email, 
        :LangID, :Registration_Source, :Registration_Source_ext,
        accounts_attributes:[:CompanyNumber, :Balance, :MinBalance, :Active, :CustomerID, :ActNbr, :ActTypeID, :BankActNbr, :RoutingNbr, :_destroy,:id])
    end
  
end
