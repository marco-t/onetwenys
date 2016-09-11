require './model/card'
require './model/deck'
require './model/hand'
require './model/kit'
require './model/human'
require './model/computer'
require './model/team'

class Game
  GOAL = 120
  
  def play_game
    @total_points = { team1: 0, team2: 0 }
    @players = create_players
    @teams = create_teams
    @dealer = draw_for_dealer
    
    round = 1
    until goal_reached? do
      puts "Round #{round}"
      play_round
      puts "Team 1: #{@team1.points}, Team 2: #{@team2.points}"
      round += 1
    end
  end
  
  private
  
  def create_players
    players = []
    players << Human.new("Mark")
    3.times { |i| players << Computer.new("Player #{i + 2}") }
    players
  end
  
  def create_teams
    @team1 = Team.new @players[0], @players[2]
    @team2 = Team.new @players[1], @players[3]

    [@team1, @team2]
  end
  
  def draw_for_dealer
    @players[rand(@players.size)]
  end
  
  def goal_reached?
    @teams.any? { |team| team.points >= GOAL }
  end
  
  def play_round
    round_points = Hash.new(0)
    move_player_to_end(@dealer)
    
    d = Deck.new.shuffle!
    deal_hands(d)
    kitty = deal_kitty(d)
    
    show_hands
    bidding_results = bidding_round

    winning_bidder = bidding_results[:player]
    winning_bid = bidding_results[:bid]

    bidding_team = @team1.players.include?(winning_bidder) ? @team1 : @team2
    nonbidding_team = @teams.reject { |t| t == bidding_team }.first

    move_player_to_front(winning_bidder)
    
    trump = winning_bidder.choose_trump
    d.set_trump_cards(trump)
    puts "Trump is #{trump}"
    
    winning_bidder.hand.add_cards(kitty.remove_cards)
    
    discard_cards
    refill_hands(d)
    
    play_tricks(round_points)
    
    if winning_bid == 30 && round_points[bidding_team] == 30
      bidding_team.points += 60
    elsif round_points[bidding_team] >= winning_bid
      bidding_team.points += round_points[bidding_team]
    else
      bidding_team.points -= winning_bid
    end
    nonbidding_team.points += round_points[nonbidding_team]

    #move dealer button
    @dealer = @players.first
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

  def show_hands
    @players.each { |p| p.show_hand }
  end
  
  def bidding_round
    bidders = @players.dup
    highest_bidder = nil
    highest_bid = 0

    until bidders.size == 1 do
      @players.each do |player|
        is_dealer = player == @dealer

        next unless bidders.include?(player)
        
        if bidders.size == 1
          # ensure dealer can play if everyone else passes
          break unless highest_bidder.nil?
        end
        
        if highest_bid == 30 && !is_dealer
          puts "#{player} can't outbid #{highest_bidder}"
          bidders.delete(player)
          next 
        end

        bid = player.bid(highest_bid, is_dealer)
        puts "#{player} bids #{bid}"
        if bid == 30 && is_dealer
          # dealer outbid everyone else
          dealer_idx = bidders.index(player)
          bidders = bidders.drop(dealer_idx)

          highest_bid = bid
          highest_bidder = player
        elsif bid == 0
          bidders.delete(player)
        elsif bid > highest_bid
          bidder_idx = bidders.index(player)
          bidders = bidders.drop(bidder_idx)

          highest_bid = bid
          highest_bidder = player
        elsif bid == highest_bid
          # only dealer can match previous bid
          highest_bid = bid
          highest_bidder = player
        end
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
  
  def discard_cards
    @players.each do |player|
      player.discard_cards
    end
  end
  
  def refill_hands(deck)
    @players.each do |p|
      cards_in_hand = p.hand.size
      cards_needed = Hand::MAX - cards_in_hand
      cards_needed.times { p.hand.add_card(deck.deal_card) }
    end
  end

  def play_tricks(round_points)
    Hand::MAX.times do |i|
      puts "Trick #{i+1}"
      trick_results = play_trick
      trick_winner = trick_results[:winner]
      trick_points = trick_results[:points]
      
      winning_team = @team1.players.include?(trick_winner) ? @team1 : @team2

      move_player_to_front(trick_winner)

      round_points[winning_team] += trick_points
    end
  end
  
  def play_trick
    pile = {}
    
    lay_cards(pile)

    pile_cards = pile.values
    winning_card = highest_card_in_pile(pile_cards)
    winning_player = winning_player(pile, winning_card)
    points = trick_points(pile_cards)

    puts "#{winning_player} wins the trick with #{winning_card}"
    { winner: winning_player, points: points }
  end

  def lay_cards(pile)
    @players.each_with_index do |player, i|
      possible_cards = determine_possible_cards(player.hand, pile)
      player.show_possible_cards(possible_cards)

      card = player.lay_card(possible_cards)
      pile[player] = card

      puts "\t #{'*' * (i+1)} #{player} laid #{card}"
    end
  end

  def determine_possible_cards(hand, pile)
    return hand if pile.empty?
    
    first_card = pile.first[1]
    return hand unless first_card.trump?

    trump_cards = hand.cards.select(&:trump?)
    return hand if trump_cards.empty?

    reneggable_cards = trump_cards.select do |c|
      c.value >= 50 && c.value > first_card.value
    end

    return hand if reneggable_cards == trump_cards

    Hand.new(trump_cards)
  end

  def highest_card_in_pile(cards)
    card_values = []
    first_suit = cards.first.suit

    cards.each do |card|
      if card.suit == first_suit || card.trump?
        card_value = card.value
      else
        card_value = 0
      end
      card_values << [card, card_value]
    end

    max = card_values.max_by { |x| x[1] }
    max[0]
  end

  def winning_player(cards, winning_card)
    cards.key(winning_card)
  end

  def trick_points(cards)
    five_trump?(cards) ? 10 : 5
  end

  def five_trump?(cards)
    cards.any? { |card| card.rank == '5' && card.trump? }
  end
end