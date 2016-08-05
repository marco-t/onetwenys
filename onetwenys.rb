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
  
  def sort_by_value
  end
  
  def size
    @cards.size
  end
  
  def to_s
    @cards.join(' | ')  
  end
end

class Card
  attr_accessor :suit, :rank, :color, :base_value
  SUITS = ["Hearts", "Clubs", "Diamonds", "Spades"]
    RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
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
    @base_value = get_base_value
  end
  
  def get_color
    if @suit == 'Hearts' || @suit == 'Diamonds'
      return 'red'
    else
      return 'black'
    end
  end
  
  def get_base_value
    return RED_VALUES[@rank] if @color == 'red'
    return BLACK_VALUES[@rank] if @color == 'black'
    puts "*****BASE VALUE ERROR*****"
  end
  
  def to_s
    "#{@rank} of #{@suit}"
  end
  
  def to_abbr
    "#{@rank}#{@suit[0].downcase}"
  end
end

class Deck
  attr_accessor :cards
  def initialize
    @cards = []
    4.times do |suit|
      13.times do |rank|
        @cards << Card.new(suit, rank)
      end
    end
  end
  
  def shuffle
    @cards.shuffle!
    self
  end
  
  def deal_card
    @cards.shift
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
    sleep 0.5
    puts "#{self} bids #{players_bid}"
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
    
    sleep 0.25
    puts "\nDealer is #{@dealer}"
    
    until goal_reached? do
      sleep 0.25
      puts "\n*\t STARTING ROUND"
      play_round
      
      #for test
      @teams[0].points = 120
    end
  end
  
  private
  
  def create_players
    4.times { |i| 
      puts "#{'*'*i.next}\t Player #{i.next} created" 
      sleep 0.1
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
    
    sleep 0.1
    puts "**\t SHUFFLING DECK"
    
    d = Deck.new.shuffle
    
    sleep 0.1
    puts "***\t DEALING HANDS"
    
    deal_hands(d)
    
    sleep 0.1
    puts "****\t DEALING KITTY\n "
    
    kitty = deal_kitty(d)
    
    bidding_results = bidding_round
    winning_bidder = bidding_results[:player]
    winning_bid = bidding_results[:bid]
    move_player_to_front(winning_bidder)
    
    sleep 0.25
    puts "\n#{winning_bidder} wins the bid with #{winning_bid}\n "
    sleep 0.25
    puts winning_bidder.hand
    
    trump = winning_bidder.choose_trump
    
    sleep 0.25
    puts "\n#{winning_bidder} says \"#{trump.upcase} is trump\"\n "
    
    winning_bidder.hand.add_cards(kitty.remove_cards)
    
    sleep 0.25
    puts winning_bidder.hand
    
    sleep 0.25
    puts "\n*\t DISCARDING CARDS\n "
    discard_cards
    
    sleep 0.25
    puts winning_bidder.hand
    
    sleep 0.25
    puts "\n*\t DEALING NEW CARDS\n "
    refill_hands(d)
    
    sleep 0.25
    puts winning_bidder.hand
    
    Hand::MAX.times do
      puts
      trick_results = play_trick(trump)
      # trick_winner = trick_results[:winner]
      # trick_points = trick_results[:points]
      # round_results[trick_winner] += trick_points
    end
    #assign points based on bet
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
    
    @players.each do |player|
      card = player.lay_card(0)
      leading_card ||= card
      leading_player ||= player
      
      sleep 0.25
      puts "#{player} lays #{card}"
      
      if card.base_value > leading_card.base_value
        leading_card = card
        leading_player = player
      end
    end
    
    sleep 0.25
    puts "\n*\t #{leading_player} wins trick with #{leading_card}"
    #{ winner: player, points: points }
  end
  
  
end
game = Onetwenys.new
game.play_game
