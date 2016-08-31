require './model/human'
require './spec/support/human'

require './model/hand'
require './spec/support/hand'
require './spec/support/card'

describe Human do
  it "can be created" do
    player = Human.new "John Doe"

    expect(player.name).to eq "John Doe"
  end
end

describe Human, '#lay_card' do
  before do
    @player = make_player
    allow(@player).to receive(:puts) # silence $stdout for tests

    @player.hand = Hand.new
    @player.hand.add_card(card("Hearts", "A"))
    @hand_size = @player.hand.size
  end

  it "removes a card from player's hand" do
    allow(@player).to receive(:gets) { 1 }
    @player.lay_card

    expect(@player.hand.size).to eq @hand_size - 1
  end

  it "responds to card position in hand" do
    allow(@player).to receive(:gets) { 1 }
    @player.lay_card

    expect(@player.hand.size).to eq @hand_size - 1
  end
end

describe Human, '#bid' do
  before do
    @player = make_player
    @dealer = false
    allow(@player).to receive(:puts) # silence $stdout for tests
  end

  it "can be received" do
    highest_bid = 0
    allow(@player).to receive(:gets) { 20 }
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 20
  end

  it "can only be 0, 20, 25 or 30" do
    highest_bid = 0
    allow(@player).to receive(:gets).and_return(5, 20)
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 20
  end

  it "is higher than last bid" do
    highest_bid = 20
    allow(@player).to receive(:gets).and_return(20, 25)
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 25
  end

  it "can always be zero" do
    highest_bid = 30
    allow(@player).to receive(:gets).and_return(0)
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 0
  end

  it "dealer can match the highest bid" do
    @dealer = true
    highest_bid = 30
    allow(@player).to receive(:gets).and_return(30)
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 30
  end
end