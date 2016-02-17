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
end

class Player
	attr_accessor :hand, :score, :dealer
	def initialize
		@hand = []
		@score = 0
		@dealer = false
	end

	def pass_deck(other_player)
		self.dealer = false
		other_player.dealer = true
	end

	def deal(deck, player1, player2, kitty)
		player1.hand.clear
		player2.hand.clear
		player1.hand << deck.cards.pop(5)
		player2.hand << deck.cards.pop(5)
		kitty << deck.cards.pop(3)
	end
end

class Round
	def initialize(player1, player2)
		@player1 = player1
		@player2 = player2
		@kitty = []
		@deck = Deck.new
		# refactor this terrible code
		if player1.dealer
			@dealer = player1
			@next_to_dealer = player2
		else
			@dealer = player2
			@next_to_dealer = player1
		end
	end

	def bid
	end

	def play_round
		@dealer.deal(@deck, @player1, @player2, @kitty)

		roundOver = false
		tricks_played = 0

		until roundOver do
			trick = Trick.new(@player1, @player2)
			trick.play_trick
			tricks_played += 1
			if tricks_played == 5
				roundOver = true
			end
		end
		@dealer.pass_deck(@next_to_dealer)
	end
end

class Trick
	def initialize(player1, player2)
		@player1 = player1
		@player2 = player2
	end

	def play_trick
		win_trick(@player1)
	end

	def win_trick(player)
		player.score += 5
		# player.score += 10 if 5 of trump in trick
	end

end

class Game
	def initialize
		@gameOver = false
		@player1 = Player.new
		@player2 = Player.new
		if rand(2) == 0
			@player1.dealer = true
		else
			@player2.dealer = true
		end
	end

	def play_game
		# player wins when their score reaches 120 or more.
		# player can only win if they placed the last bet
		until (@player1.score >= 120 || @player2.score >= 120) do
			round = Round.new(@player1, @player2)
			round.play_round
		end
	end
end

game = Game.new
game.play_game

# player1 = Player.new
# player2 = Player.new
# deck = Deck.new
# kitty = []
# deck.deal(player1, player2, kitty)
# puts player1.hand
# puts
# puts player2.hand
# puts
# puts kitty