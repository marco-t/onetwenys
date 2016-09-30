class Hand
  include Enumerable
  attr_reader :cards
  
  MAX = 5
  def initialize(cards = [])
    @cards = cards
  end

  def each(&block)
    @cards.each { |member| block.call(member) }
  end

  def <<(card)
    add_card(card)
  end
  
  def add_card(card)
    @cards << card
  end
  
  def add_cards(cards)
    @cards << cards
    @cards.flatten!
  end
  
  def remove_card(card)
    if card.is_a? Card
      delete(card)
    elsif card.is_a? Integer
      @cards.delete_at(card)
    elsif card.nil?
      raise ArgumentError.new('Card cannot be nil')
    else
      raise StandardError
    end
  end

  def sort
    sorted_by_value = @cards.sort.reverse
    partitions = sorted_by_value.partition(&:trump?)
    non_trumps = partitions.last
    groups = non_trumps.group_by(&:suit)

    [partitions.first, groups.values].flatten
  end

  def sort!
    @cards = sort
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

  private

  def delete(card)
    index = @cards.index { |c| c.eql? card }
    @cards.delete_at(index)
  end

  def sort_by_suit
    @cards.sort_by(&:suit)
  end
end