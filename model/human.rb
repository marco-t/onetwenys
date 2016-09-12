$LOAD_PATH << './model'
require 'player'
require 'outputer'

class Human < Player
  include Outputer

  def show_hand
    @hand.show if @hand.size > 0
  end

  def show_possible_cards(possible_cards)
    possible_cards.show
  end

  def bid(highest_bid, dealer)
    valid_bids = dealer ? valid_dealer_bids(highest_bid) : valid_nondealer_bids(highest_bid)

    user_input = nil
    until valid_bids.include?(user_input) do
      output_line "Place your bid #{valid_bids}: "

      user_input = get_number
      clear_line
    end

    user_input
  end

  def choose_trump
    output_line "What suit will be trump? "

    get_suit
  end

  def discard_cards
    loop do
      self.show_hand

      user_input = nil
      break if @hand.size == 0

      min = @hand.size <= 5 ? 0 : 1
      max = @hand.size

      until (min..max).include? user_input do
        output_line "Pick a card to discard (#{min} to #{max}): "

        user_input = get_number
        clear_line
      end
      clear_lines(3)

      break if user_input == 0
      @hand.remove_card(user_input - 1)
    end
  end

  def lay_card(possible_cards)
    user_input = nil
    until (1..possible_cards.size).include?(user_input) do
      output_line "Choose a card (between 1 and #{possible_cards.size}): "

      user_input = get_number
      clear_line
    end
    clear_lines(3)

    card_position = user_input - 1
    card = possible_cards[card_position]
    @hand.remove_card(card)
  end

  private

  def get_number
    gets.chomp.to_i
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