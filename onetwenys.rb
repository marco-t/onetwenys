# use linked lists to pass dealer button and take turns??

class Game
  # number of players must be even
  def initialize(number_of_players)
    @gameOver = false
    @players = []
    number_of_players.times do |i|
      name = "Player #{i+1}"
      @players << Player.new(name)
    end
    @players[0][:human] = true

    # assign teams
    number_of_teams = number_of_players / 2
    @teams = []
    number_of_teams.times do |i|
      @teams << Team.new(@players[i], @players[i+2])
    end

    # draw for dealer
    rand = rand(number_of_players)
    @players[rand][:dealer] = true
  end

  def play_game
    # team wins when their score reaches 120 or more.
    # team can only win if they placed the last bet

    #until @gameOver do
    1.times do # Play once for testing
      round = Round.new(@players, @teams)
      round.play_round
      @teams.each do |team|
        team.score = team.mate1[:score] + team.mate2[:score]
        @gameOver = true if team.score >= 120
      end
    end
  end
end

class Round
  def initialize(players, teams)
    @players = players
    @teams = teams
    
    @kitty = []
    @deck = Deck.new

    # move dealer to end of array keeping player order
    temp_array = @players.dup
    @players.reverse_each do |player|
      unless player[:dealer]
        popped_player = temp_array.pop
        temp_array.unshift(popped_player)
      else
        @dealer = player
        break
      end
    end
    @players = temp_array.dup
  end

  def move_winner_to_front(winner)
    @players.reverse_each do |player|
      popped_player = @players.pop
      @players.unshift(popped_player)
      if popped_player == winner
        break
      end
    end
  end

  def play_round
    @dealer.deal(@deck, @players, @kitty)

    trump = [:clubs, :spades, :hearts, :diamonds].shuffle!.pop
    puts "Dealer is #{@dealer}"
    puts "Trump is #{trump.to_s.upcase}"
    5.times do
      trick = Trick.new(@players, @teams)
      winner = trick.play_trick(trump)
      move_winner_to_front(winner)
    end

    # index of dealer
    i = @players.index do |player|
      player[:dealer]
    end

    # if last player was dealer make first player dealer, otherwise next player deals
    @players[i][:dealer] = false
    @players[i+1].nil? ? @players[0][:dealer] = true : @players[i+1][:dealer] = true
  end
end

class Trick
  def initialize(players, teams)
    @players = players
    @teams = teams
  end

  # each player lays a card. Winner is returned
  def play_trick(trump)
    winning_player = nil
    trick = []
    until trick.count == @players.count do
      winning_card, winning_player = nil, nil
      @players.each.with_index do |player, i|
        if player[:human]
          player.show_hand
          card_laid = player.lay_card
        else
          card_laid = player.ai_lay_card
        end
        card_laid.set_value(trump, trick[0])
        trick << card_laid
        puts "Player #{player[:name]} laid #{card_laid}. Value: #{card_laid[:value]}"
        
        winning_card ||= card_laid
        winning_player ||= player
        if card_laid[:value] > winning_card[:value]
          winning_card = card_laid 
          winning_player = player
        end
      end
    end
    puts "#{winning_player} wins the trick"; puts
    winning_player.increase_score(trick)
    winning_player
  end
end

class Deck
  attr_accessor :cards

  def initialize
    suits = [:clubs, :spades, :hearts, :diamonds]
    numbers = %w(2 3 4 5 6 7 8 9 10 J Q K A)
    @cards = []
    suits.each do |suit|
      numbers.each do |number|
        abrv = (number.to_s + suit.to_s.chr).to_sym
        suit == :clubs || suit == :spades ? color = :black : color = :red
        card = Card.new
        card.update(name: abrv, number: number, suit: suit, color: color, value: nil)
        @cards << card
      end
    end
    @cards.shuffle!
  end
end

class Card < Hash
  def to_s
    "#{self[:number]} of #{self[:suit].to_s.capitalize}"
  end

  def set_value(trump, first_card = nil)
    # sets first suit to card's suit if no other card was played
    first_card.nil? ? first_suit = self[:suit] : first_suit = first_card[:suit]
    
    red_values = { 'K' => 13, 'Q' => 12, 'J' => 11, '10' => 10, '9' => 9, '8' => 8, '7' => 7, 
                 '6' => 6, '5' => 5, '4' => 4, '3' => 3, '2' => 2, 'A' => 1 }

    black_values = { 'K' => 13, 'Q' => 12, 'J' => 11, 'A' => 10, '2' => 9, '3' => 8, '4' => 7,
                   '5' => 6, '6' => 5, '7' => 4, '8' => 3, '9' => 2, '10' => 1  }

    if self[:name] == :Ah
      self[:value] = 50
    elsif self[:suit] == trump
      if self[:number] == '5'
        self[:value] = 52
      elsif self[:number] == 'J'
        self[:value] = 51
      elsif self[:number] == 'A'
        self[:value] = 49
      elsif self[:color] == :black
        self[:value] = black_values[self[:number]] + 35
      elsif self[:color] == :red
        self[:value] = red_values[self[:number]] + 35
      end
    elsif self[:suit] == first_suit
      if self[:color] == :black
        self[:value] = black_values[self[:number]]
      else
        self[:value] = red_values[self[:number]]
      end
    else
      self[:value] = 0
    end
  end
end

class Team
  # change mate1 and mate2. ugly names
  attr_accessor :score, :mate1, :mate2
  def initialize(teammate1, teammate2)
    @mate1 = teammate1
    @mate2 = teammate2
    @score = 0
  end

  def thirty_for_sixty
    # if team bids 30 and wins all tricks in the round they get 60 points
    new_score = @mate1[:score] + @mate2[:score]
    if new_score - score == 30
      @mate1[:score] += 15
      @mate2[:score] += 15
    end
    score = @mate1[:score] + @mate2[:score]
  end
end

class Player < Hash
  # should have :name, :dealer, :score, :human
  attr_accessor :hand
  def initialize(name)
    self[:name] = name
    self[:dealer] = false
    self[:score] = 0
    @hand = []
  end

  def to_s
    "#{self[:name]}"
  end

  def deal(deck, players, kitty)
    # clear old cards in hands, if any, deal 5 cards to each player
    players.each do |player|
      player.hand.clear
      player.hand = deck.cards.pop(5)
    end

    # add three cards to empty kitty
    kitty = deck.cards.pop(3)
  end

  def bet(amount)
  end

  def show_hand
    @hand.each do |card|
      print "| #{card} "
    end
    print '|'
    puts
  end

  def lay_card
    card = nil
    until (1..@hand.length).include? card
      begin
        print "Choose a card (between 1 and #{@hand.length}): "
        card = Integer(gets)
        puts
      rescue
        retry
      end
    end
    @hand.slice!(card-1)
  end

  def ai_lay_card
    @hand.pop
  end

  def increase_score(trick)
    score = nil
    trick.each do |card|
      # a trick with the 5 of trump is worth 10 points
      if card[:value] == 52
        score = 10
      else
        score ||= 5
      end
    end
    puts "#{self[:name]} scored #{score} points!"
    self[:score] += score
  end
end

puts
number_of_players = 4
game = Game.new(number_of_players)
game.play_game