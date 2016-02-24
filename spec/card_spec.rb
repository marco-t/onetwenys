require_relative '../onetwenys'

describe Card do
  before(:each) do
    @card = Card.new
  end

  context 'trump' do
    it 'should have value greater than 35' do
      @card[:trump] = true
      @card.set_value
      expect(@card[:value]).to be > 35
    end
  end
end