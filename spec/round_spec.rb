require_relative '../onetwenys'

class Game
  attr_accessor :players, :teams
end

class Round
  attr_accessor :dealer
end

describe Round do
  before(:each) do
    game = Game.new(4)
    @players = game.players
    @teams = game.teams
    @round = Round.new(@players, @teams)
    @dealer = @round.dealer
  end

  it { expect(@round).to be_an_instance_of(Round) }
  it 'dealer should be set' do
    expect(@dealer).to be_truthy
  end

  it 'number of dealers should be one' do
    number_of_dealers = 0
    @players.each { |player| number_of_dealers += 1 if player[:dealer]}
    expect(number_of_dealers).to be 1
  end

  it 'method should move player to back' do
    player1 = @players.first
    players_reordered = @round.move_player_to_back(player1)
    expect(players_reordered.first).not_to equal player1
    expect(players_reordered.last).to equal player1
  end

  it 'method should move player to front' do
    player4 = @players.last
    players_reordered = @round.move_player_to_front(player4)
    expect(players_reordered.last).not_to equal player4
    expect(players_reordered.first).to equal player4
  end

end