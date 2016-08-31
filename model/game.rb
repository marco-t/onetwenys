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
    
    until goal_reached? do
      play_round
      
      #for test
      @teams[0].points = 120
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
    
    d = Deck.new.shuffle!
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
      move_player_to_front(trick_winner)
      round_results[trick_winner.name] += trick_points
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

          highest_bid = 30
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
  
  def play_trick(trump)
    leading_card = nil
    leading_player = nil
    points = 5
    
    @players.each_with_index do |player, i|
      card_value = nil
      card = player.lay_card
      points = 10 if card.rank == '5' && card.trump?

      leading_card ||= card
      leading_player ||= player
      
      if card.suit == leading_card.suit || card.trump?
        if card.value > leading_card.value
          leading_card = card
          leading_player = player
        end
      else
        card_value = 0
      end
      puts "\t #{'*' * (i+1)} #{player} laid #{card} (value: #{card_value || card.value})"
    end

    { winner: leading_player, points: points }
  end
  
  def tally_point(round_result)
  end
end