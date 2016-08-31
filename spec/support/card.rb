require './model/card'

def card(s, r)
  suit = Card::SUITS.find_index(s)
  rank = Card::RANKS.find_index(r.to_s)
  Card.new(suit, rank)
end