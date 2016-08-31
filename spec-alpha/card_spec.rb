require_relative '../onetwenys'

describe Card do
  before(:each) do
    @card = Card.new
    @trump = :clubs
    @card.update(name: :'10c', rank: '10', suit: @trump, color: :black)
  end

  it 'Ace of Hearts should be trump' do
    @card.update(name: :Ah, rank: 'A', suit: :hearts, color: :red)
    @card.set_value(@trump)
    expect(@card[:trump]).to be true
  end

  it 'should have value greater than 35' do
    @card.set_value(@trump)
    expect(@card[:value]).to be > 35
  end

  it 'first card laid has value between 0 and 35' do
    first_card = Card.new
    first_card.update(name: :'10h', rank: '10', suit: :hearts, color: :red)
    first_card.set_value(@trump)
    expect(first_card[:value]).to be > 0
    expect(first_card[:value]).to be < 35
  end

  it 'second card has no value if off-suit and not trump' do
    first_card, second_card = Card.new, Card.new
    first_card.update(name: :'10h', rank: '10', suit: :hearts, color: :red)
    second_card.update(name: :'10d', rank: '10', suit: :diamonds, color: :red)
    second_card.set_value(@trump, first_card)
    expect(second_card[:value]).to be 0
  end
end