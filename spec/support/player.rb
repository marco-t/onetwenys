require './model/computer'
require './model/human'
require './model/hand'
require './spec/support/card'

def make_human
  Human.new "John Doe"
end

def make_computer
  Computer.new "John Doe"
end

def full_hand
  hand = Hand.new
  hand.add_card(card("Hearts", "A"))
  hand.add_card(card("Hearts", "K"))
  hand.add_card(card("Clubs", "8"))
  hand.add_card(card("Spades", "2"))
  hand.add_card(card("Diamonds", "5"))
  hand
end

def trump_hand
  hand = Hand.new
  hand.add_card(card("Hearts", "5"))
  hand.add_card(card("Hearts", "J"))
  hand.add_card(card("Hearts", "A"))
  hand.add_card(card("Hearts", "K"))
  hand.add_card(card("Hearts", "10"))

  hand.cards.each { |c| c.trump! }
  hand
end