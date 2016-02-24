require_relative '../onetwenys'

describe Game do 
  before(:each) do
    number_of_players = 4
    @game = Game.new(number_of_players)
  end

  it { expect(@game).to be_an_instance_of(Game) }
end

describe Player do
  before(:each) do
    @player = Player.new('Player 1')
  end

  it { expect(@player).to be_an_instance_of(Player) }
  it { expect(@player[:name]).to eq 'Player 1' }

end

describe Deck do
  before(:each) do
    @deck = Deck.new
  end

  it 'should have 52 cards' do
    expect(@deck.cards.length).to eq 52
  end
end

describe Card do
  before(:each) do
    @card = Card.new
  end

  context 'trump' do
    it 'should have value greater than 35' do
      @card[:trump] = true
      @card.set_value
      expect(@card[:value]).to be > 35
    end
  end
end