Goal = class()
Goal.size = 25

function Goal:init()
  self.x = ctx.map.width - self.size
  self.y = ctx.map.height - ctx.map.ground.height - self.size
  ctx.event:emit('view.register', {object = self})
end

function Goal:draw()
  local g = love.graphics
  g.setColor(0, 255, 0)
  g.rectangle('line', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
end
