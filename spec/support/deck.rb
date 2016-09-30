require './model/deck'

def all_cards(deck)
  deck.map { |card|  }

  cards = []
  while true do
    card = deck.deal_card
    break if card.nil?
    cards << card
  end
  cards
end

def all_cards_by_name(deck)
  cards = []
  while true do
    card = deck.deal_card
    break if card.nil?
    cards << card.to_s
  end
  cards
end

def all_trump?(cards)
  cards.all? {|card| card.trump? }
end