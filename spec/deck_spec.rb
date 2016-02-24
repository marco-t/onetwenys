require_relative '../onetwenys'

describe Deck do
  before(:each) do
    @deck = Deck.new
  end

  it 'should have 52 cards' do
    expect(@deck.cards.length).to eq 52
  end
end