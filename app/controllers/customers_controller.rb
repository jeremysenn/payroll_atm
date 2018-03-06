class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
  def index
    @employees = current_user.company.customers.employees.last(20)
  end
  
  def show
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:ParentCustID, :CompanyNumber, :Active, :GroupID, :NameF, :NameL, :NameS, :PhoneMobile, :Email, 
        :LangID, :Registration_Source, :Registration_Source_ext, :course_id, :type, :company_id,
        accounts_attributes:[:CompanyNumber, :Balance, :MinBalance, :Active, :CustomerID, :ActNbr, :ActTypeID, :BankActNbr, :RoutingNbr, :_destroy,:id])
    end
  
end
