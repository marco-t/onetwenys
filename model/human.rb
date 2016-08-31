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
      user_input = get_number
    end

    user_input
  end

  def choose_trump
    print "What suit will be trump? "
    get_suit
  end

  def discard_cards
    loop do
      user_input = nil
      break if @hand.size == 0

      min = @hand.size <= 5 ? 0 : 1
      max = @hand.size

      until (min..max).include? user_input do
        print "Pick a card to discard (#{min} to #{max}): "
        user_input = get_number
      end

      break if user_input == 0
      @hand.remove_card(user_input - 1)
    end
  end

  def lay_card
    user_input = nil
    until (1..@hand.size).include?(user_input) do
      print "Choose a card (between 1 and #{@hand.size}): "
      user_input = get_number
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

  def get_number
    Integer(gets)
  end

  def get_suit
    input = gets[0].downcase

    case input
    when 'c'
      return 'Clubs'
    when 'h'
      return 'Hearts'
    when 'd'
      return 'Diamonds'
    when 's'
      return 'Spades'
    end
  end
end