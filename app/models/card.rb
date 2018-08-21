class Card < ActiveRecord::Base
  establish_connection :ez_cash
#  self.primary_key = 'card_nbr'
  self.primary_key = 'card_seq'
  
  belongs_to :device, :foreign_key => 'dev_id'
  belongs_to :company
  
  #############################
  #     Instance Methods      #
  #############################
  
  def active?
    card_status == "AC"
  end
  
  def closed?
    card_status == "CL"
  end
  
  def void?
    card_status == "VD"
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.to_csv
    require 'csv'
    attributes = %w{last_activity_date issued_date card_status bank_id_nbr card_nbr dev_id receipt_nbr card_amt avail_amt}
    
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |card|
        csv << attributes.map{ |attr| card.send(attr) }
      end
    end
  end
  
end