class WelcomeController < ApplicationController
#  before_action :authenticate_user!
  
  def index
    if user_signed_in?
      if current_user.payee?
        if not current_user.temporary_password.blank?
          flash[:error] = "You must update your password."
          redirect_to edit_registration_path(current_user)
        else
          redirect_to current_user.customer
        end
      end
      if current_user.admin?
        @devices = current_user.company.devices
#        @processed_payment_batches = current_user.company.payment_batches.processed.order("created_at DESC").first(3)
        @payees_count = current_user.company.customers.count
        
        # Transfers Info
        @transfers = current_user.company.transactions.transfers.where(date_time: 1.week.ago.beginning_of_day..Date.today.end_of_day).order("date_time DESC")
        @transfers_week_data = []
        grouped_transfers = @transfers.group_by{ |t| t.date_time.day }
        (1.week.ago.to_date..Date.today).each do |date|
          transfers_group_total = 0
          grouped_transfers.each do |group, transfers|
            if date.day == group
              transfers.each do |transfer|
                transfers_group_total = transfers_group_total + transfer.amt_auth.to_f
              end
            end
          end
          @transfers_week_data << transfers_group_total
        end
        @transfers_count = @transfers.count
        @transfers_amount = 0
        @transfers.each do |transfer_transaction|
          @transfers_amount = @transfers_amount + transfer_transaction.amt_auth unless transfer_transaction.amt_auth.blank?
        end
        
        # Withdrawals Info
        @withdrawals = current_user.company.transactions.withdrawals.where(date_time: 1.week.ago.beginning_of_day..Date.today.end_of_day).order("date_time DESC")
#        @withdrawals_week_data = @withdrawals.map{|t| t.amt_auth.to_f}
        
        @withdrawals_week_data = []
        grouped_withdrawals = @withdrawals.group_by{ |t| t.date_time.day }
        (1.week.ago.to_date..Date.today).each do |date|
          withdrawals_group_total = 0
          grouped_withdrawals.each do |group, withdrawals|
            if date.day == group
              withdrawals.each do |withdrawals|
                withdrawals_group_total = withdrawals_group_total + withdrawals.amt_auth.to_f
              end
            end
          end
          @withdrawals_week_data << withdrawals_group_total
        end
        
        @withdrawals_count = @withdrawals.count
        @withdrawals_amount = 0
        @withdrawals.each do |withdrawal_transaction|
          @withdrawals_amount = @withdrawals_amount + withdrawal_transaction.amt_auth
        end
        
        @week_of_dates_data = (1.week.ago.to_date..Date.today).map{ |date| date.strftime('%-m/%-d') }
      end
    end
  end
  
end
