class Team
  attr_accessor :players, :points
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @players = [@player1, @player2]
    
    @points = 0
  end
end