Goal = class()
Goal.size = 25

function Goal:init()
  self.x = ctx.map.width - ctx.view.width / 2
  self.y = ctx.map.height - ctx.map.ground.height - self.size
  self.image = data.media.graphics.bread
  ctx.event:emit('view.register', {object = self})
end

function Goal:draw()
  local g = love.graphics
  g.setColor(255, 255, 255)
  local height = 100
  local scale = height / self.image:getHeight()
  g.draw(self.image, self.x + self.image:getWidth() * scale / 2, self.y - height / 2, math.sin(ls.tick / 10) / 10, scale, scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end
