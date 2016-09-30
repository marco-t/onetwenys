require './spec/support/player'
require './spec/support/outputer_off'

describe Human do
  it "can be created" do
    player = Human.new "John Doe"

    expect(player.name).to eq "John Doe"
  end
end

describe Human, '#discard_cards' do
  before do
    @player = make_human

    @player.hand = full_hand
    @hand = @player.hand
    @initial_size = @hand.size
  end

  it "removes card(s) from player's hand" do
    allow(@player).to receive(:gets).and_return("1", "0")
    @player.discard_cards

    final_size = @hand.size

    expect(final_size).to eq @initial_size - 1
  end

  it "end when hand is empty" do
    allow(@player).to receive(:gets).and_return("5", "4", "3", "2", "1")
    @player.discard_cards

    final_size = @hand.size

    expect(final_size).to eq 0
  end
end

describe Human, '#lay_card' do
  before do
    @player = make_human

    @player.hand = Hand.new
    @possible_cards = @player.hand
    @player.hand.add_card(card("Hearts", "A"))
    @hand_size = @player.hand.size
  end

  it "removes a card from player's hand" do
    allow(@player).to receive(:gets) { "1" }
    @player.lay_card(@possible_cards)

    expect(@player.hand.size).to eq @hand_size - 1
  end

  it "responds to card position in hand" do
    allow(@player).to receive(:gets) { "1" }
    @player.lay_card(@possible_cards)

    expect(@player.hand.size).to eq @hand_size - 1
  end
end

describe Human, '#bid' do
  before do
    @player = make_human
    @dealer = false
  end

  it "can be received" do
    highest_bid = 0
    allow(@player).to receive(:gets) { "20" }
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 20
  end

  it "can only be 0, 20, 25 or 30" do
    highest_bid = 0
    allow(@player).to receive(:gets).and_return("5", "20")
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 20
  end

  it "is higher than last bid" do
    highest_bid = 20
    allow(@player).to receive(:gets).and_return("20", "25")
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 25
  end

  it "can always be zero" do
    highest_bid = 30
    allow(@player).to receive(:gets).and_return("0")
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 0
  end

  it "dealer can match the highest bid" do
    @dealer = true
    highest_bid = 30
    allow(@player).to receive(:gets).and_return("30")
    bid = @player.bid(highest_bid, @dealer)

    expect(bid).to eq 30
  end
end