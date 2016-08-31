require './model/human'

def make_player
  Human.new "John Doe"
end

def make_full_hand
  hand = Hand.new
  hand.add_card(card("Hearts", "A"))
  hand.add_card(card("Hearts", "K"))
  hand.add_card(card("Clubs", "8"))
  hand.add_card(card("Spades", "2"))
  hand.add_card(card("Diamonds", "5"))
  hand
end