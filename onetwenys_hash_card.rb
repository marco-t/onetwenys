class Game
  # number of players must be even
  def initialize(number_of_players)
    @gameOver = false
    @players = []
    number_of_players.times do |i|
      name = "Player #{i+1}"
      @players << Player.new(name)
    end

    # assign teams
    number_of_teams = number_of_players / 2
    @teams = []
    number_of_teams.times do |i|
      @teams << Team.new(@players[i], @players[i+2])
    end

    # draw for dealer
    rand = rand(number_of_players)
    @players[rand].dealer = true
  end

  def play_game
    # player wins when their score reaches 120 or more.
    # player can only win if they placed the last bet

    #until @gameOver do
    1.times do # change this
      round = Round.new(@players, @teams)
      round.play_round
      @teams.each do |team|
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

    # who is the dealer this round?
    players.each do |player|
      @dealer = player if player.dealer == true
    end
  end

  def trump=(trump)
    @trump = trump
  end

  def play_round
    @dealer.deal(@deck, @players, @kitty)
    self.trump = [:clubs, :spades, :hearts, :diamonds].shuffle!.pop
    puts "Trump is #{@trump.to_s.upcase}"
    5.times do
      trick = Trick.new(@players, @teams)
      winner = trick.play_trick(@trump)
      puts "The winner is #{winner.name}"; puts
    end

    # index of dealer
    i = @players.index do |player|
      player.dealer == true
    end

    @players[i].dealer = false
    # if last player was dealer make first player dealer
    @players[i+1].nil? ? @players[0].dealer = true : @players[i+1].dealer = true
  end
end

class Trick
  def initialize(players, teams)
    @players = players
    @teams = teams
    @trick = []
  end

  # each player lays a card. Winner is returned
  def play_trick(trump)
    winning_player = nil
    until @trick.count == @players.count do
      winning_card, winning_player = nil, nil
      @players.each.with_index do |player, i|
        card_to_lay = -1
        card_laid = player.lay_card(card_to_lay)
        set_card_value(trump, card_laid, @trick[0])
        @trick << card_laid
        puts "Player #{i+1} laid #{card_laid[:number]} of #{card_laid[:suit].capitalize}. Value: #{card_laid[:value]}"
        winning_card ||= card_laid
        winning_player ||= player
        if card_laid[:value] > winning_card[:value]
          winning_card = card_laid 
          winning_player = player
        end
      end
    end
    winning_player
  end

  def set_card_value(trump, card, first_card = nil)
    # sets first suit to card's suit if no other card was played
    first_card.nil? ? first_suit = card[:suit] : first_suit = first_card[:suit]
    
    red_values = { 'K' => 13, 'Q' => 12, 'J' => 11, '10' => 10, '9' => 9, '8' => 8, '7' => 7, 
                 '6' => 6, '5' => 5, '4' => 4, '3' => 3, '2' => 2, 'A' => 1 }

    black_values = { 'K' => 13, 'Q' => 12, 'J' => 11, 'A' => 10, '2' => 9, '3' => 8, '4' => 7,
                   '5' => 6, '6' => 5, '7' => 4, '8' => 3, '9' => 2, '10' => 1  }

    if card[:name] == :Ah
      card[:value] = 50
    elsif card[:suit] == trump
      if card[:number] == '5'
        card[:value] = 52
      elsif card[:number] == 'J'
        card[:value] = 51
      elsif card[:number] == 'A'
        card[:value] = 49
      elsif card[:color] == :black
        card[:value] = black_values[card[:number]] + 35
      elsif card[:color] == :red
        card[:value] = red_values[card[:number]] + 35
      end
    elsif card[:suit] == first_suit
      if card[:color] == :black
        card[:value] = black_values[card[:number]]
      else
        card[:value] = red_values[card[:number]]
      end
    else
      card[:value] = 0
    end
  end

  def winning_team(trick)

  end

  def win_trick(team)
    team.score += 5
    # team.score += 10 if 5 of trump in trick
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
        card = { name: abrv, number: number, suit: suit, color: color, value: nil }
        @cards << card
      end
    end
    @cards.shuffle!
  end
end

class Team
  attr_accessor :score, :mate1, :mate2
  def initialize(teammate1, teammate2)
    @mate1 = teammate1
    @mate2 = teammate2
    @score = 0
  end
end

class Player
  attr_accessor :hand, :dealer, :name
  def initialize(name)
    @name = name
    @hand = []
    @dealer = false
  end

  def deal(deck, players, kitty)
    # clear old hands if any, deal 5 cards to each player
    players.each do |player|
      player.hand.clear
      player.hand = deck.cards.pop(5)
    end

    # add three cards to empty kitty
    kitty = deck.cards.pop(3)
  end

  def bet(amount)
  end

  # requires an integer from zero to @hand.length
  def lay_card(card)
    @hand.slice!(card)
  end
end

puts
number_of_players = 4
game = Game.new(number_of_players)
game.play_game

