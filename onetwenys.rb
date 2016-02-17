class Deck
	attr_accessor :cards

	def initialize
		suits = [:clubs, :spades, :hearts, :diamonds]
		numbers = %w(2 3 4 5 6 7 8 9 10 J Q K A)
		@cards = []
		suits.each do |suit|
			numbers.each do |number|
				@cards << Card.new(number, suit)
			end
		end
		@cards.shuffle!
	end
end

class Card
	attr_accessor :suit, :color, :number, :value, :trump
	def initialize(number, suit)
		@number = number
		@suit = suit
		@trump = false
		if @suit == :clubs || @suit == :spades
			@color = :black
		else
			@color = :red
		end
	end

	def to_s
		"#{number} of #{suit.capitalize}"
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
	attr_accessor :hand, :dealer
	def initialize
		@hand = []
		@dealer = false
	end

	def pass_deck(other_player)
		self.dealer = false
		other_player.dealer = true
	end

	def deal(deck, players, kitty)
		# clear old hands if any, deal 5 cards to each player
		players.each do |player|
			player.hand.clear
			player.hand << deck.cards.pop(5)
		end

		# add three cards to empty kitty
		kitty << deck.cards.pop(3)
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

	def bet
	end

	def play_round
		@dealer.deal(@deck, @players, @kitty)

		roundOver = false
		tricks_played = 0

		until roundOver do
			trick = Trick.new(@players, @teams)
			trick.play_trick
			tricks_played += 1
			if tricks_played == 5
				roundOver = true
			end
		end

		# index of dealer
		i = @players.rindex do |player|
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
	end

	def play_trick

		win_trick(@teams[0])
	end

	def win_trick(team)
		team.score += 5
		# player.score += 10 if 5 of trump in trick
	end

end

class Game
	# number of players must be even
	def initialize(number_of_players)
		@gameOver = false
		@players = []
		number_of_players.times do |i|
			@players << Player.new
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
		1.times do
			round = Round.new(@players, @teams)
			round.play_round
			@teams.each do |team|
				@gameOver = true if team.score >= 120
			end
		end			
	end
end

number_of_players = 4
game = Game.new(number_of_players)
game.play_game