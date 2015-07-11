Hud = class()

function Hud:init()
  self.font = love.graphics.newFont(12)
end

function Hud:draw()
  local g = love.graphics
  g.setColor(255, 255, 255)

  local barWidth = 100
  local barHeight = 10
  local p = ctx.pigeon
  g.rectangle('fill', 2, 2, barWidth * (p.health / p.maxHealth), barHeight)
  g.rectangle('line', 2, 2, barWidth, barHeight)

  g.setFont(self.font)
  g.print('Lives: ' .. p.lives, barWidth + 10, 2)
end
