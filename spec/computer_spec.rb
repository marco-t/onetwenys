require './model/computer'
require './spec/support/computer'

require './model/hand'
require './spec/support/hand'
require './spec/support/card'

describe Computer, '#discard_cards' do
  before do
    @player = make_player
  end

  it "removes non-trump cards" do
    @player.hand = full_hand
    hand = @player.hand
    hand[0].trump!
    @player.discard_cards

    expect(hand.size).to eq 1
  end

  it "removes lowest card when size > 5" do
    @player.hand = trump_hand
    hand_names = @player.hand.cards.map { |c| c.to_abbr }

    card = card("Hearts", "2")
    card.trump!
    @player.hand.add_card(card)

    @player.discard_cards
    new_hand_names = @player.hand.cards.map { |c| c.to_abbr }

    expect(@player.hand.size).to eq 5
    expect(hand_names).to eq new_hand_names
  end
end