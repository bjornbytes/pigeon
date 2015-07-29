Building = class()

Building.size = 60

function Building:activate()
  self.y = ctx.map.height - ctx.map.ground.height
  self.image = data.media.graphics.dinoland['hut' .. love.math.random(1, 2)]

  self.personTimer = 6 + love.math.random() * 3

  ctx.event:emit('view.register', {object = self})
end

function Building:update()
  self.personTimer = timer.rot(self.personTimer, function()
    ctx.enemies:add(Caveman, {x = self.x, y = self.y - 20})
    return 6 + love.math.random() * 3
  end)
end

function Building:draw()
  local g = love.graphics
  local scale = self.size / self.image:getWidth()
  g.setColor(255, 255, 255)
  g.draw(self.image, self.x, self.y, 0, scale, scale, self.image:getWidth() / 2, self.image:getHeight())
end

