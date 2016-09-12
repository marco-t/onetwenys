require './model/hand'
require './spec/support/card'

def full_hand
  cards = [
    card("Spades", "5"),
    card("Hearts", "A"),
    card("Diamonds", "5"),
    card("Clubs", "5"),
    card("Diamonds", "A")
  ]

  Hand.new(cards)
end

def five_sorted_cards
  return [
    card("Diamonds", "5"),
    card("Hearts", "A"),
    card("Diamonds", "A"),
    card("Clubs", "5"),
    card("Spades", "5")
  ]
end

def set_trump(hand, trump)
  hand.cards.each do |c|
    c.trump! if c.suit == trump || c.to_abbr == 'Ah'
  end
end