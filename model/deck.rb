require './model/card'

class Deck
  include Enumerable

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
    all do |card|
      if card.suit == trump_suit
        card.trump!
      end
    end
    set_Ah_to_trump
  end

  def all(&block)
    @all.each { |member| block.call(member) }
  end

  def each(&block)
    @remaining.each { |member| block.call(member) }
  end
  
  private
  
  def set_Ah_to_trump
    all do |card|
      if card.to_abbr == 'Ah'
        card.trump!
        break
      end
    end
  end
end