require_relative '../onetwenys'

describe Player do
  before(:each) do
    @player = Player.new('Player 1')
  end

  it { expect(@player).to be_an_instance_of(Player) }
  it { expect(@player[:name]).to eq 'Player 1' }
end