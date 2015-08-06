require 'require'

function love.load()
  data.load()
  Context:bind(Game, 'Dinoland', 3)
end
