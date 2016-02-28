require_relative 'onetwenys'

class Game
  attr_accessor :players, :teams
end

human_players = 4
teams = false
game = Game.new(human_players, teams)
game.play_game

