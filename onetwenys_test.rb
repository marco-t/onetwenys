require_relative 'onetwenys'

class Game
  attr_accessor :players, :teams
end

human_players = 1
teams = false
game = Game.new(human_players, teams)
game.play_game

