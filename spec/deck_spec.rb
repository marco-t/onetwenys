require './model/deck'
require './spec/support/deck'

describe Deck do
  it "has 52 unique cards" do
    deck = Deck.new
    cards = all_cards_by_name(deck)
    unique_cards = cards.uniq.size

    expect(unique_cards).to equal 52
  end
end

describe Deck, '#deal_card' do
  it "removes card from the deck" do
    deck = Deck.new
    full_deck_size = deck.size
    deck.deal_card

    expect(deck.size).to equal full_deck_size - 1
  end

  it "first card should be Ace of Heart" do
    deck = Deck.new
    first_card = deck.deal_card

    expect(first_card.to_s).to eq("A of Hearts")
  end
end

describe Deck, '#shuffle!' do
  it "cards are randomized" do
    deck = Deck.new
    card1 = deck.deal_card.to_s

    deck = Deck.new.shuffle!
    card2 = deck.deal_card.to_s

    expect(card1).not_to eq(card2)
  end
end

describe Deck, '#set_trump_cards' do
  it "sets same suit to trump" do
    deck = Deck.new
    cards = all_cards(deck)

    trump = 'Clubs'
    deck.set_trump_cards(trump)
    clubs = cards.select_suit(trump)

    expect(all_trump?(clubs)).to be true
  end

  it "does not set other suits to trump" do
    deck = Deck.new
    cards = all_cards(deck)

    trump = 'Clubs'
    deck.set_trump_cards(trump)
    diamonds = cards.select_suit('Diamonds')

    expect(all_trump?(diamonds)).to be false
  end

  it "sets the Ace of Hearts to trump" do
    deck = Deck.new
    cards = all_cards(deck)

    trump = 'Clubs'
    deck.set_trump_cards(trump)

    ace_of_hearts = cards.first
    expect(ace_of_hearts.trump?).to be true
  end
end