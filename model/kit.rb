class Kit
  attr_accessor :cards
  def initialize
    @cards = []
  end
  
  def add_card(card)
    @cards << card
  end
  
  def remove_cards
    cards = @cards
    @cards = []
    cards
  end
end