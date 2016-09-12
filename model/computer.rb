$LOAD_PATH << './model'
require 'player'

class Computer < Player

  def show_hand
  end

  def show_possible_cards(possible_cards)
  end

  def bid(highest_bid, dealer)
    if dealer
      valid_bids = valid_dealer_bids(highest_bid)
    else
      valid_bids = valid_nondealer_bids(highest_bid)
    end
  
    valid_bids.sample
  end

  def choose_trump
    best_suit
  end

  def discard_cards
    @hand.cards.each { |c| @hand.remove_card(c) unless c.trump? }
    until @hand.size <= 5
      @hand.remove_card(@hand.cards.min)
    end
  end

  def lay_card(possible_cards)
    card_position = rand(possible_cards.size)
    card = possible_cards[card_position]
    @hand.remove_card(card)
  end

  private

  def best_suit
    Card::SUITS[rand(4)]
  end
end