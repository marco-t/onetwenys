# use linked lists to pass dealer button and take turns??

class Game
  # number of players must be even
  def initialize(number_of_players)
    @game_over = false
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
      @players[i][:team] = i + 1
      @players[i+2][:team] = i + 1
    end

    # draw for dealer
    rand = rand(number_of_players)
    @players[rand][:dealer] = true
  end

  def play_game
    # team wins when their score reaches 120 or more.
    # team can only win if they placed the last bet

    #until @game_over do
    1.times do # Play once for testing
      round = Round.new(@players, @teams)
      round.play_round
      @teams.each do |team|
        team.score = team.mate1[:score] + team.mate2[:score]
        @game_over = true if team.score >= 120
      end
    end
  end
end

class Round
  def initialize(players, teams)
    @players = players
    @teams = teams
    
    @deck = Deck.new
    @kitty = []
    @bid = { amount: 0, player: nil, team: nil }


    # move dealer
    @players.each do |player|
      @dealer = player if player[:dealer]
    end
    move_player_to_back(@dealer)
  end

  def move_player_to_back(player)
    temp_array = @players.dup
    @players.reverse_each do |p|
      unless p == player
        popped_player = temp_array.pop
        temp_array.unshift(popped_player)
      else
        break
      end
    end
    @players = temp_array.dup
  end

  def move_player_to_front(player)
    @players.reverse_each do
      popped_player = @players.pop
      @players.unshift(popped_player)
      if popped_player == player
        break
      end
    end
  end

  def play_round
    puts "Dealer is #{@dealer}"
    @dealer.deal(@deck, @players, @kitty)

    # Show human player's hand before bidding
    @players.each do |player|
      player.show_hand if player[:human]
    end
    bidding(@players)
    move_player_to_front(@bid[:player])

    trump = [:clubs, :spades, :hearts, :diamonds].shuffle!.pop
    puts "Trump is #{trump.to_s.upcase}"
    puts "#{@bid[:player]} goes first"
    5.times do
      trick = Trick.new(@players, @teams)
      winner = trick.play_trick(trump)
      move_player_to_front(winner)
    end

    # index of dealer
    i = @players.index do |player|
      player[:dealer]
    end

    # if last player was dealer make first player dealer, otherwise next player deals
    @players[i][:dealer] = false
    @players[i+1].nil? ? @players[0][:dealer] = true : @players[i+1][:dealer] = true
  end

  def bidding(players)
    # make sure they are ordered properly with dealer bidding last
    last_bid = 0
    bidding_player = nil
    players.each do |player|
      if player[:human]
        valid = false
        error = ''
        msg = 'Bid (0|20|25|30): '
        until valid
          begin
            print error+msg
            bid = Integer(gets)
            puts
          rescue
            error = "Invalid input.\n"
            retry
          end
          if bid == 0 || bid == 20 || bid == 25 || bid == 30
            if bid == 0 # pass
              valid = true
            elsif bid == last_bid
              if player[:dealer]
                puts 'Mine.'
                bidding_over = false
                until bidding_over
                  # last bidder gets chance to bid higher than dealer
                  # then dealer get chance to say "Mine." again then repeat
                  # until bid == 30 or dealer says "Go on."
                  # bid = Integer(gets)
                  # . . . not useful when only one human player
                  bidding_over = true
                end
                last_bid = bid
                bidding_player = player
                valid = true
              else
                error = "Bid higher than #{last_bid}\n"
              end
            elsif bid > last_bid
              valid = true
              last_bid = bid
              bidding_player = player
            else
              error = "Bid higher than #{last_bid}\n"
            end
          else
            error = "Invalid input.\n"
          end
        end
      else # player is not human
        if last_bid == 0
          bid = [0, 20].shuffle.pop
          if bid > last_bid
            last_bid = bid
            bidding_player = player
          end
        else
          bid = 0
        end
      end
      puts "#{player[:name]} bids #{bid}"
    end
    if last_bid == 0
      last_bid = 20
      bidding_player = players.last # dealer
    end
    team = bidding_player[:team]
    @bid.update(amount: last_bid, player: bidding_player, team: team)
    puts "Team #{@bid[:team]} wins bid with #{@bid[:amount]}"
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
        puts "#{player[:name]} laid #{card_laid}. Value: #{card_laid[:value]}"
        
        winning_card ||= card_laid
        winning_player ||= player
        if card_laid[:value] > winning_card[:value]
          winning_card = card_laid 
          winning_player = player
        end
      end
    end
    puts "#{winning_player} wins the trick"
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
  # should have :name, :team, :dealer, :score, :human
  attr_accessor :hand
  def initialize(name)
    self[:name] = name
    self[:team] = nil
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

  def show_hand
    chars = @hand.join(" ").length + @hand.length*6 + 2
    puts '#' * chars
    print '| '
    @hand.each.with_index do |card, i|
      print "(#{i+1}) #{card} | "
    end
    puts 
    puts '#' * chars
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
    puts "#{self[:name]} scored #{score} points!"; puts
    self[:score] += score
  end
end

puts
number_of_players = 4
game = Game.new(number_of_players)
game.play_game