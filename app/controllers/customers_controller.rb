class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
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
    @account = @employee.accounts.first
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
