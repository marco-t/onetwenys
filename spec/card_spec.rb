require './spec/support/card'

describe Card do
  it "has the right color" do
    heart   = card("Hearts", "A")
    club    = card("Clubs", "A")
    diamond = card("Diamonds", "A")
    spade   = card("Spades", "A")

    expect(heart.color).to eq 'red'
    expect(club.color).to eq 'black'
    expect(diamond.color).to eq 'red'
    expect(spade.color).to eq 'black'
  end
end

describe Card, '#trump?' do
  it "returns true if card is trump" do
    card = card("Clubs", "A")
    card.trump!

    expect(card).to be_trump
  end

  it "returns false if card is not trump" do
    card = card("Clubs", "A")

    expect(card).not_to be_trump
  end
end

describe Card, '#value' do
  it "high in red, low in black" do
    ten_hearts = card("Hearts", "10")
    ten_clubs = card("Clubs", "10")

    two_hearts = card("Hearts", "2")
    two_clubs = card("Clubs", "2")

    expect(ten_hearts).to be > ten_clubs
    expect(two_hearts).to be < two_clubs
  end

  it "trump beats cards of other suit" do
    ten_hearts = card("Hearts", "10")
    ten_diamonds = card("Diamonds", "10")

    ten_hearts.trump!

    expect(ten_hearts).to be > ten_diamonds
  end

  it "Ace of Hearts beats Ace of Trump" do
    ace_hearts = card("Hearts", "A")
    ace_diamonds = card("Diamonds", "A")
    ace_hearts.trump!
    ace_diamonds.trump!

    expect(ace_hearts).to be > ace_diamonds
  end
end