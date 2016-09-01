class Computer
  attr_accessor :name, :hand

  def initialize(name)
    @name = name
  end

  def to_s
    "#{@name}"
  end

  def show_hand
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

  def lay_card
    card_position = (0...@hand.size).to_a.sample
    @hand.remove_card(card_position)
  end

  private

  def valid_nondealer_bids(highest_bid)
    [0, 20, 25, 30].keep_if do |num|
      num > highest_bid || num.zero?
    end
  end

  def valid_dealer_bids(highest_bid)
    valid_bids = [20, 25, 30].keep_if do |num|
      num >= highest_bid
    end
    valid_bids.unshift(0) unless highest_bid.zero?
    valid_bids
  end
end