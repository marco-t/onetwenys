require_relative '../onetwenys'

describe Game do 
  before(:each) do
    number_of_players = 4
    @game = Game.new(number_of_players)
  end

  it { expect(@game).to be_an_instance_of(Game) }
end