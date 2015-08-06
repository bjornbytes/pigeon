require 'require'

function love.load()
  data.load()
  Context:bind(Game, 'Dinoland', 2)
end
