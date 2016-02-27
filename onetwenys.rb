class Game
  def initialize(human_players, teams = true)
    create_players(human_players)
    teams ? play_with_teams : play_without_teams
    draw_for_dealer
  end

  def create_players(human_players)
    total_players = 4
    @players = []
    total_players.times do |i|
      name = "Player #{i+1}"
      @players << Player.new(name)
      @players[i][:human] = true if i+1 <= human_players
    end
  end

  def play_with_teams
    @teams = []
    2.times do |i|
      @teams << Team.new(@players[i], @players[i+2])
      @teams[i].name = "Team #{i+1}"
      @players[i][:team] = @teams[i]
      @players[i+2][:team] = @teams[i]
    end
  end

  def play_without_teams
    @teams = []
    4.times do |i|
      @teams << Team.new(@players[i])
      @teams[i].name = "Team #{i+1}"
      @players[i][:team] = @teams[i]
    end
  end

  def draw_for_dealer
    rand = rand(@players.size)
    @players[rand][:dealer] = true
  end

  def play_game
    # team wins when their score reaches 120 or more.
    # team can only win if they placed the last bet

    game_over = false
    #until game_over do
    1.times do # Play once for testing
      round = Round.new(@players, @teams)
      game_over = round.play_round
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
    @scores = {}
    @teams.each do |team|
      @scores[team] = 0 # @scores is difficult to understand
    end

    # move dealer to end of array
    @players.each { |player| @dealer = player if player[:dealer] }
    move_player_to_back(@dealer)
  end

  def move_player_to_back(player)
    i = @players.index(player)
    @players.rotate!(i)
    @players.rotate!
  end

  def move_player_to_front(player)
    i = @players.index(player)
    @players.rotate!(i)
  end

  def play_round
    puts "Dealer is #{@dealer}"
    @dealer.deal(@deck, @players, @kitty)

    # Show human player's hand before bidding
    @players.each { |player| player.show_hand if player[:human] }
    winning_bidder = bidding(@players)
    move_player_to_front(winning_bidder)

    trump = winning_bidder.choose_trump
    winning_bidder.take_kitty(@kitty)
    @players.each { |player| player.discard_draw_cards(@deck, trump) }

    puts "#{winning_bidder} goes first"
    5.times do
      trick = Trick.new(@players, @teams)
      winner, winner_points = trick.play_trick(trump)
      @scores[winner[:team]] += winner_points
      puts "\n#{winner} wins the trick (#{@scores[winner[:team]]} points)\n"
      puts '-' * 44; puts
      move_player_to_front(winner)
    end

    adjust_team_scores
    move_dealer_to_next_player
    return game_over?
  end

  def adjust_team_scores
    @teams.each do |team|
      if team == @bid[:team]
        if @scores[team] >= @bid[:amount]
          @scores[team] = 60 if @bid[:amount] == 30 
          team.score += @scores[team]
          print "#{team} gained #{@scores[team]} points "
        else
          team.score -= @bid[:amount]
          print "#{team} lost #{@bid[:amount]} points "
        end
      else
        if team.score + @scores[team] < 120
          team.score += @scores[team] 
          print "#{team} gained #{@scores[team]} points "
        else
          print "*** #{team} needs to bid to win *** "
        end
      end
      puts "(#{team.score} points)"
    end
  end

  def move_dealer_to_next_player
    # if last player was dealer make first player dealer, otherwise next player deals
    d = @players.index { |player| player[:dealer] }
    @players[d][:dealer] = false
    @players[d+1].nil? ? @players[0][:dealer] = true : @players[d+1][:dealer] = true
  end

  def game_over?
    @teams.each do |team|
      return true if team.score >= 120
    end
    false
  end

  def bidding(players)
    bids = []
    amounts = [20, 25, 30]
    players.each do |player|
      bid = {}
      if !player[:dealer] && amounts.size > 0 # unless player[:dealer] && amounts.size < 1 ???
        amounts.unshift(0)
        amount = player.choose_bid(amounts)
        amounts.delete_if { |n| n <= amount }

        bid[:player] = player
        bid[:amount] = amount
        bids << bid unless bid[:amount] == 0
        puts "#{player[:name]} bids #{amount}"
      end
      if player[:dealer]
        loop do
          dealer_amounts = [20, 25, 30]
          if bids.size > 0
            # don't pass if no one else bid
            dealer_amounts.delete_if { |n| n < bids.last[:amount] }
            dealer_amounts.unshift(0)
          end
          amount = player.choose_bid(dealer_amounts)
          if amount == 0
            puts "Go on"
            break
          else
            bid[:player] = player
            bid[:amount] = amount
            if bids.size > 0
              puts "Mine" if amount == bids.last[:amount]
              last_bidder = bids.last[:player]
            end
            puts "#{player[:name]} bids #{amount}"
            bids << bid
            break if amount == 30
            amounts.delete_if { |n| n <= amount }
            break if bids.size == 1
          end
          # last bidder can bid higher or pass
          amount = last_bidder.choose_bid(amounts) # 0 should be in there already
          bid[:player] = last_bidder
          bid[:amount] = amount
          puts "#{last_bidder[:name]} bids #{amount}"
          bids << bid
        end
      end
    end
    winning_player = bids.last[:player]
    winning_bid = bids.last[:amount]
    winning_team = winning_player[:team]
    @bid.update(amount: winning_bid, player: winning_player, team: winning_team)
    winning_player
  end
end

class Trick
  def initialize(players, teams)
    @players = players
    @teams = teams
  end

  # each player lays a card. Winner and winner's points are returned
  def play_trick(trump)
    winning_player = nil # probably don't need this
    trick = []
    until trick.count == @players.count do
      winning_card, winning_player, first_card = nil, nil, nil
      @players.each.with_index do |player, i|
        card_laid = player.lay_card(trump, first_card)
        card_laid.set_value(trump, trick[0]) if card_laid[:value].nil?
        trick << card_laid
        print_move(player, card_laid, i)
        
        first_card ||= card_laid
        winning_card ||= card_laid
        winning_player ||= player
        if card_laid[:value] > winning_card[:value]
          winning_card = card_laid 
          winning_player = player
        end
      end
    end
    return winning_player, trick_points(trick)
  end

  def print_move(player, card_laid, i)
    spacer = "+" * (i+1)
    str = "#{spacer} #{player[:name]} laid #{card_laid}"
    spaces = " " * (34 - str.length)
    puts "#{str}#{spaces} Value: #{card_laid[:value]}"
  end

  def trick_points(trick)
    points = nil
    trick.each do |card|
      # a trick with the 5 of trump is worth 10 points
      if card[:value] == 52
        points = 10
      else
        points ||= 5
      end
    end
    points
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
        card.update(name: abrv, number: number, suit: suit, color: color, trump: false, value: nil)
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
    self[:trump] = true if self[:suit] == trump
    # sets first suit to card's suit if no other card was played
    first_card.nil? ? first_suit = self[:suit] : first_suit = first_card[:suit]
    
    red_values = { 'K' => 13, 'Q' => 12, 'J' => 11, '10' => 10, '9' => 9, '8' => 8, '7' => 7, 
                 '6' => 6, '5' => 5, '4' => 4, '3' => 3, '2' => 2, 'A' => 1 }

    black_values = { 'K' => 13, 'Q' => 12, 'J' => 11, 'A' => 10, '2' => 9, '3' => 8, '4' => 7,
                   '5' => 6, '6' => 5, '7' => 4, '8' => 3, '9' => 2, '10' => 1  }

    if self[:name] == :Ah
      self[:trump] = true
      self[:value] = 50
    elsif self[:trump]
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
  attr_accessor :name, :score, :mate1, :mate2
  def initialize(teammate1, teammate2 = nil)
    @score = 0
    @mate1 = teammate1
    @mate2 = teammate2 unless teammate2.nil?
  end

  def to_s
    no_teams = "#{mate1}"
    with_teams = "#{@name} (#{mate1}, #{mate2})"
    return no_teams if mate2.nil?
    return with_teams
  end
end

class Player < Hash
  # should have [:name], [:team], [:dealer], [:human]
  attr_accessor :hand
  def initialize(name)
    self[:name] = name
    self[:team] = nil
    self[:dealer] = false
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
    3.times { kitty << deck.cards.pop }
  end

  def choose_bid(allowed_bids)
    if self[:human]
      valid = false
      error = ''
      msg = "Bid #{allowed_bids.join('|')}: "
      until valid
        begin
          print "#{error}\n#{msg}"
          bid = Integer(gets)
          error = ''
          puts
        rescue
          error = "Invalid input"
          retry
        end
        if allowed_bids.include? bid
          valid = true
        else
          error = "Invalid input"
        end
      end
    else
      bid = allowed_bids.shuffle.sample
    end
    bid
  end

  def choose_trump
    if self[:human]
      suits = %w(clubs spades hearts diamonds)
      chars = suits.join(' ').length + suits.length*6 + 2
      puts '=' * chars
      print '| '
      suits.each.with_index do |suit, i|
        print "(#{i+1}) #{suit} | "
      end
      puts
      puts '=' * chars
      begin
        valid = false
        until valid
          print 'What is trump? '
          num = Integer(gets)
          puts
          if [1, 2, 3, 4].include? num
            trump = suits.fetch(num-1).to_sym
            valid = true
          end
        end
      rescue
        retry
      end
    else
      trump = [:clubs, :spades, :hearts, :diamonds].shuffle!.pop
    end
    puts "Trump is #{trump.to_s.capitalize}"
    trump
  end

  def take_kitty(kitty)
    @hand = @hand + kitty
    show_hand if self[:human]
  end

  def discard_draw_cards(deck, trump)
    temp_card = Card.new
    temp_card[:suit] = trump

    discard_cards(trump, temp_card)
    draw_cards(deck)

    @hand.each do |card|
      if card[:suit] == trump || card[:abrv] == :Ah # <-- probably unnecessary
        card.set_value(trump, temp_card)
      end
    end
  end

  def discard_cards(trump, temp_card)
    if self[:human]
      discard = nil
      until discard == 0
        show_hand(@hand)
        @hand.size <= 5 ? min = 0 : min = 1
        max = @hand.size
        discard = nil
        until (min..max).include? discard
          begin
            puts "Pick a card to discard (#{min} - #{max})"
            discard = Integer(gets)
            puts
          rescue
            retry
          end
        end
        @hand.delete_at(discard-1) unless discard == 0
      end
    else
      # cards with no or low value are automatically discarded
      @hand.each { |card| card.set_value(trump, temp_card) }
      @hand.keep_if { |card| card[:value] > 0 }
      @hand.sort_by! { |card| card[:value] }.reverse!
      @hand.pop until @hand.length <= 5
    end
  end

  def draw_cards(deck)
    # player dealt new cards until hand is full
    @hand << deck.cards.pop until @hand.length >= 5
  end

  def show_hand(possible_cards = nil)
    if possible_cards.nil?
      hand = @hand
    else
      hand = possible_cards
    end
    chars = hand.join(" ").length + hand.length*6 + 2
    puts '#' * chars
    print '| '
    hand.each.with_index do |card, i|
      print "(#{i+1}) #{card} | "
    end
    puts 
    puts '#' * chars
  end

  def lay_card(trump, first_card = nil)
    # BUG --> Ah is not a possible card when trump led
    possible_cards = @hand.dup
    if first_card.nil?
      card = choose_card(possible_cards)
    else
      if first_card[:trump]
        possible_cards = @hand.reject { |c| c[:trump] == false }
        if possible_cards.length > 0
          trumps_above_first_card = 0
          possible_cards.each do |c|
            trumps_above_first_card += 1 if c[:value] >= 50 && c[:value] > first_card[:value]
          end
          # renegging
          possible_cards = @hand.dup if trumps_above_first_card == possible_cards.size
          card = choose_card(possible_cards)
        else
          possible_cards = @hand.dup
          card = choose_card(possible_cards)
        end
      else
        card = choose_card(possible_cards)
      end
    end
    card_played = possible_cards.slice!(card)
    @hand.delete(card_played)
    card_played
  end

  def choose_card(cards)
    card = nil
    if self[:human]
      until (1..cards.length).include? card
        show_hand(cards)
        begin
          print "Choose a card (between 1 and #{cards.length}): "
          card = Integer(gets)
          puts
        rescue
          retry
        end
      end
      card -= 1
    else
      card = rand(cards.length)
    end
    card
  end
end