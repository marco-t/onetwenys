class Card
  attr_accessor :suit, :rank
  attr_reader :color
  SUITS = ["Hearts", "Clubs", "Diamonds", "Spades"]
  RANKS = %w(A 2 3 4 5 6 7 8 9 10 J Q K)
  RED_VALUES = { 
    'K' => 13, 'Q' => 12, 'J' => 11, '10' => 10,
    '9' => 9, '8' => 8, '7' => 7, '6' => 6,
    '5' => 5, '4' => 4, '3' => 3, '2' => 2, 'A' => 1
  }
  BLACK_VALUES = { 
    'K' => 13, 'Q' => 12, 'J' => 11, 'A' => 10,
    '2' => 9, '3' => 8, '4' => 7, '5' => 6,
    '6' => 5, '7' => 4, '8' => 3, '9' => 2, '10' => 1
  }
  
  def initialize(suit, rank)
    @suit = SUITS[suit]
    @rank = RANKS[rank]
    @color = get_color
    @trump = false
  end

  def value
    trump? ? trump_value : base_value
  end

  def trump!
    @trump = true
  end
  
  def trump?
    @trump
  end
  
  def to_s
    "#{@rank} of #{@suit}"
  end
  
  def to_abbr
    "#{@rank}#{@suit[0].downcase}"
  end
  
  private

  def get_color
    if @suit == 'Hearts' || @suit == 'Diamonds'
      'red'
    else
      'black'
    end
  end
  
  def base_value
    return RED_VALUES[@rank] if @color == 'red'
    return BLACK_VALUES[@rank] if @color == 'black'
  end

  def trump_value
    if @rank == '5'
      52
    elsif @rank == 'J'
      51
    elsif @rank == 'A' 
      @suit == 'Hearts' ? 50 : 49
    else
      base_value + 35
    end
  end
end