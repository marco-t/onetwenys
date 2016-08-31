require_relative '../onetwenys'

describe Deck do
  before(:each) do
    @deck = Deck.new
  end

  it 'should have 52 cards' do
    expect(@deck.cards.length).to eq 52
  end

  it 'should be shuffled' do
    suits = [:clubs, :spades, :hearts, :diamonds]
    numbers = %w(2 3 4 5 6 7 8 9 10 J Q K A)
    cards = []
    suits.each do |suit|
      numbers.each do |number|
        abrv = (number.to_s + suit.to_s.chr).to_sym
        card = Card.new
        card.update(name: abrv)
        cards << card
      end
    end

    expect(@deck.cards).not_to eql cards
  end
end