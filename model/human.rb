class Human
  attr_accessor :name, :hand
  def initialize(name)
    @name = name
  end
  
  def to_s
    "#{@name}"
  end

  def bid(highest_bid, dealer)
    if dealer
      valid_bids = valid_dealer_bids(highest_bid)
    else
      valid_bids = valid_nondealer_bids(highest_bid)
    end

    user_input = nil
    until valid_bids.include?(user_input) do
      print "Place your bid #{valid_bids}: "
      user_input = get_input
    end

    user_input
  end

  def lay_card
    user_input = nil
    until (1..@hand.size).include?(user_input) do
      print "Choose a card (between 1 and #{@hand.size}): "
      user_input = get_input
    end

    card_position = user_input - 1
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

  def get_input
    Integer(gets)
  end
end