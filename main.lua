require 'require'

function love.load()
  data.load()
  Context:bind(Game, 'Kingdumb', 3)
end
