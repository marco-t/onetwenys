# Rules: http://play120s.weebly.com/rules.html 
# and  : http://www.upalong.org/games_120s.asp

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
  
  def remove_card(card_position)
    @cards.delete_at(card_position)
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

class Card
  attr_accessor :suit, :rank, :color, :trump, :base_value, :value
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
    @base_value = get_base_value
  end
  
  def get_color
    if @suit == 'Hearts' || @suit == 'Diamonds'
      return 'red'
    else
      return 'black'
    end
  end
  
  def trump?
    @trump
  end
  
  def trump_value
    if @rank == '5'
      return 52
    elsif @rank == 'J'
      return 51
    elsif @rank == 'A' 
      @suit == 'Hearts' ? 50 : 49
    else
      return @base_value + 35
    end
  end
  
  def first_card(cards)
  end
  
  def to_s
    "#{@rank} of #{@suit}"
  end
  
  def to_abbr
    "#{@rank}#{@suit[0].downcase}"
  end
  
  private
  
  def get_base_value
    return RED_VALUES[@rank] if @color == 'red'
    return BLACK_VALUES[@rank] if @color == 'black'
  end
end

class Deck
  attr_accessor :all
  def initialize
    @all = []
    4.times do |suit|
      13.times do |rank|
        @all << Card.new(suit, rank)
      end
    end
    @remaining = Array.new(@all)
  end
  
  def shuffle
    @remaining.shuffle!
    self
  end
  
  def deal_card
    @remaining.shift
  end
  
  def set_trump_cards(trump_suit)
    @all.each do |card|
      if card.suit == trump_suit
        card.trump = true
      end
    end
    set_Ah_to_trump
  end
  
  private
  
  def set_Ah_to_trump
    @all.first.trump = true
  end
end

class Player
  attr_accessor :name, :hand
  def initialize(name)
    @name = name
  end
  
  def to_s
    "#{@name}"
  end
  
  def choose_trump
    Card::SUITS[rand(4)]
  end
  
  # currently random
  def bid(highest_bid)
    players_bid = nil
    possible_bids = [0, 20, 25, 30].keep_if { |n| n.zero? || n > highest_bid }
    until players_bid do
      num = rand(possible_bids.size)
      players_bid = possible_bids[num]
    end
    players_bid
  end
  
  def lay_card(card_position)
    @hand.remove_card(card_position)
  end
end

class Team
  attr_accessor :players, :points
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @points = 0
  end
end

class Onetwenys
  GOAL = 120
  
  def play_game
    @total_points = { team1: 0, team2: 0 }
    @players = create_players
    @teams = create_teams
    @dealer = draw_for_dealer
    
    
    until goal_reached? do
      play_round
      
      #for test
      @teams[0].points = 120
    end
  end
  
  private
  
  def create_players
    4.times { |i| 
    }
    4.times.map { |i| Player.new "Player #{i.next}" }
  end
  
  def create_teams
    2.times.map { |i| Team.new @players[i], @players[i+2] }
  end
  
  def draw_for_dealer
    @players[rand(@players.size)]
  end
  
  def goal_reached?
    @teams.any? { |team| team.points >= GOAL }
  end
  
  def play_round
    round_results = Hash.new(0)
    move_player_to_end(@dealer)
    
    
    d = Deck.new.shuffle
    
    
    deal_hands(d)
    
    
    kitty = deal_kitty(d)
    
    bidding_results = bidding_round
    winning_bidder = bidding_results[:player]
    winning_bid = bidding_results[:bid]
    move_player_to_front(winning_bidder)
    
    
    trump = winning_bidder.choose_trump
    d.set_trump_cards(trump)
    
    
    winning_bidder.hand.add_cards(kitty.remove_cards)
    
    
    discard_cards
    
    
    refill_hands(d)
    
    
    Hand::MAX.times do
      trick_results = play_trick(trump)
      trick_winner = trick_results[:winner]
      trick_points = trick_results[:points]
      round_results[trick_winner] += trick_points
    end
    
    #assign points based on bet
    #tally_points(round_results)
    #move dealer button
  end
  
  def deal_hands(deck)
    @players.each do |p| 
      p.hand = Hand.new
      Hand::MAX.times { p.hand.add_card(deck.deal_card) }
      p.hand.sort_by_suit!
    end
  end
  
  def deal_kitty(deck)
    kitty = Kit.new
    3.times { kitty.add_card(deck.deal_card) }
    kitty
  end
  
  # need to account for dealer
  def bidding_round
    highest_bidder = @players[0] # temporary
    highest_bid = 0
    @players.each do |player|
      bid = player.bid(highest_bid)
      if bid > highest_bid
        highest_bid = bid
        highest_bidder = player
      end
    end
    
    { player: highest_bidder, bid: highest_bid }
  end
  
  def move_player_to_end(player)
    @players.rotate! until @players.last == player
  end
  
  def move_player_to_front(player)
    idx = @players.index(player)
    @players.rotate!(idx)
  end
  
  # this method is set to discard random # of cards for now
  def discard_cards
    @players.each do |p|
      n = rand(Hand::MAX)
      n.times { p.hand.remove_card(0) }
      if p.hand.size > 5
        until p.hand.size == 5 do
          p.hand.remove_card(0)
        end
      end
    end
  end
  
  def refill_hands(deck)
    @players.each do |p|
      cards_in_hand = p.hand.size
      cards_needed = Hand::MAX - cards_in_hand
      cards_needed.times { p.hand.add_card(deck.deal_card) }
    end
  end
  
  def play_trick(trump)
    leading_card = nil
    leading_player = nil
    points = 5
    
    @players.each do |player|
      card = player.lay_card(0)
      card.value = card_value(card, leading_card)
      
      points = 10 if card.rank == '5' && card.suit == trump
      leading_card ||= card
      leading_player ||= player
      
      
      if card.value > leading_card.value
        leading_card = card
        leading_player = player
      end
    end
    

    { winner: leading_player, points: points }
  end
  
  def card_value(card, leading_card)
    return card.trump_value if card.trump?
    return card.base_value if leading_card.nil?
    return card.base_value if card.suit == leading_card.suit
    0
  end
  
  def tally_point(round_result)
    
  end
end
game = Onetwenys.new
game.play_game
