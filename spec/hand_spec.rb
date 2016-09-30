require './spec/support/hand'

describe Hand, '#add_card' do
  it "adds card to hand" do
    hand = Hand.new
    empty_hand = hand.size
    hand << "card"

    expect(hand.size).to be > empty_hand
  end
end

describe Hand, '#sort!' do
  before do
    @hand = full_hand
    set_trump(@hand, "Diamonds")
    @hand.sort!
  end

  it "puts highest value card in front" do
    card_values = @hand.cards.map { |c| c.value }

    expect(card_values.first).to eq card_values.max
  end

  it "puts trump cards before non-trump cards" do
    number_of_trumps = @hand.cards.count(&:trump?)
    trumps_in_front = @hand.cards.take_while(&:trump?).size

    expect(trumps_in_front).to eq number_of_trumps
  end

  it "sorts non-trumps by suit and value" do
    x = @hand.cards.map { |c| c.to_abbr }
    sorted_cards = five_sorted_cards.map { |c| c.to_abbr }

    expect(x).to eq sorted_cards
  end
end