require './model/hand'
require './model/card'
require './spec/support/hand'

describe Hand, '#add_card' do
  it "adds card to hand" do
    hand = Hand.new
    empty_hand = hand.size
    hand.add_card("card")

    expect(hand.size).to be > empty_hand
  end
end