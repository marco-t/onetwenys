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
    deck1 = Deck.new
    names1 = deck1.map { |card| card.to_abbr }

    deck2 = Deck.new.shuffle!
    names2 = deck2.map { |card| card.to_abbr }

    expect(names1).not_to eq(names2)
  end
end

describe Deck, '#set_trump_cards' do
  it "sets same suit to trump" do
    deck = Deck.new

    trump = 'Clubs'
    deck.set_trump_cards(trump)
    clubs = deck.select { |card| card.suit == 'Clubs'}
    clubs_trump = clubs.all? { |card| card.trump? }

    expect(clubs_trump).to be true
  end

  it "does not set other suits to trump" do
    deck = Deck.new

    trump = 'Clubs'
    deck.set_trump_cards(trump)
    diamonds = deck.select { |card| card.suit == 'Diamonds'}
    diamonds_trump = diamonds.any? { |card| card.trump? }

    expect(diamonds_trump).to be false
  end

  it "sets the Ace of Hearts to trump" do
    deck = Deck.new

    trump = 'Clubs'
    deck.set_trump_cards(trump)

    ace_of_hearts = deck.first
    expect(ace_of_hearts.trump?).to be true
  end
end