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
    nontrumps = @hand.cards.reject { |c| c.trump? }
    nontrumps.each { |c| @hand.remove_card(c) }

    until @hand.size <= 5
      @hand.remove_card(lowest_card)
    end
  end

  def lay_card(possible_cards)
    card_position = rand(possible_cards.size)
    card = possible_cards[card_position]
    removed_card = @hand.remove_card(card)
  end

  private

  def lowest_card
    @hand.sort.last
  end

  def best_suit
    Card::SUITS[rand(4)]
  end
end