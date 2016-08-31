class Hand
  attr_accessor :cards
  
  MAX = 5
  def initialize
    @cards = []
  end
  
  def add_card(card)
    @cards << card
  end
  
  def add_cards(cards)
    @cards << cards
    @cards.flatten!
  end
  
  def remove_card(card)
    if card.is_a?(Fixnum)
      @cards.delete_at(card)
    elsif card.is_a?(String)
      @cards.delete_if { |c| card == c.to_abbr }
    end
  end
  
  def sort_by_suit!
    @cards.sort_by! {|c| c.suit}
  end
  
  def sort_by_value!
    @cards.sort_by! do |card|
      if card.trump?
        card.trump_value
      else
        card.base_value
      end
    end.reverse!
  end
  
  def size
    @cards.size
  end
  
  def to_s
    @cards.join(' | ')  
  end
end