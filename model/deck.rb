require './model/card'

class Deck
  def initialize
    @all = []
    4.times do |suit|
      13.times do |rank|
        @all << Card.new(suit, rank)
      end
    end
    @remaining = Array.new(@all)
  end
  
  def shuffle!
    @remaining.shuffle!
    self
  end
  
  def deal_card
    @remaining.shift
  end

  def size
    @remaining.size
  end
  
  def set_trump_cards(trump_suit)
    @all.each do |card|
      if card.suit == trump_suit
        card.trump!
      end
    end
    set_Ah_to_trump
  end
  
  private
  
  def set_Ah_to_trump
    @all.first.trump!
  end
end