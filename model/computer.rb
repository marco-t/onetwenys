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
    Card::SUITS[rand(4)]
  end

  def discard_cards
    n = rand(Hand::MAX)
    n.times { self.hand.remove_card(0) }
    if self.hand.size > 5
      until self.hand.size == 5 do
        self.hand.remove_card(0)
      end
    end
  end

  def lay_card(possible_cards)
    card_position = rand(possible_cards.size)
    card = possible_cards[card_position]
    @hand.remove_card(card)
  end
end