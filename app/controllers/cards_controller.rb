class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  helper_method :cards_sort_column, :cards_sort_direction
  
  def index
#    @cards = Kaminari.paginate_array(Card.order(sort_column + ' ' + sort_direction)).page(params[:cards_page]).per(20)
    @cards = Kaminari.paginate_array(current_user.company.cards.order(cards_sort_column + ' ' + cards_sort_direction)).page(params[:cards_page]).per(20)
  end
  
  def show
  end
  
  private
  
    def set_card
      @card = Card.find(params[:id])
    end

    ### Secure the cards sort direction ###
    def cards_sort_direction
      %w[asc desc].include?(params[:cards_direction]) ?  params[:cards_direction] : "desc"
    end

    ### Secure the cards sort column name ###
    def cards_sort_column
      ["card_nbr", "bank_id_nbr", "dev_id", "card_amt", "avail_amt", "card_status", "issued_date", "last_activity_date", "receipt_nbr", "barcodeHash", "card_seq"].include?(params[:cards_sort]) ? params[:cards_sort] : "last_activity_date"
    end
end
