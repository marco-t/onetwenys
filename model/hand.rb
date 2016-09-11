class Hand
  attr_reader :cards
  
  MAX = 5
  def initialize(cards = [])
    @cards = cards
  end
  
  def add_card(card)
    @cards << card
  end
  
  def add_cards(cards)
    @cards << cards
    @cards.flatten!
  end
  
  def remove_card(card)
    if card.is_a? Integer
      @cards.delete_at(card)
    elsif card.is_a? String
      @cards.delete_if { |c| c.to_abbr == card }
    elsif card.is_a? Card
      @cards.delete(card)
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

  def [](key)
    key.is_a?(Integer) ? @cards[key] : nil
  end
  
  def to_s
    @cards.join(' | ')  
  end

  def show
    chars = @cards.join(" ").length + @cards.length*6 + 2
    puts '#' * chars
    print '| '
    @cards.each.with_index do |card, i|
      print "(#{i+1}) #{card} | "
    end
    puts 
    puts '#' * chars
  end
end