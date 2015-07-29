Map = class()

function Map:init()
  self.ground = {}
  self.ground.height = self.groundHeight
  self.ground.body = love.physics.newBody(ctx.world, self.width / 2, self.height - self.ground.height / 2, 'static')
  self.ground.shape = love.physics.newRectangleShape(self.width, self.ground.height)

  self.ground.fixture = love.physics.newFixture(self.ground.body, self.ground.shape)
  self.ground.fixture:setCategory(ctx.categories.ground)

  self.ground.body:setUserData(self)

  ctx.view.xmax = self.width
  ctx.view.ymax = self.height
  ctx.event:emit('view.register', {object = self})
end

function Map:update()
  ctx.view.xmax = self:getMaxX()

  table.each(self.obstacles, function(obstacle)
    if ctx.pigeon.body:getY() + ctx.pigeon.shapeSize / 2 > obstacle.body:getY() - obstacle.height / 2 then
      obstacle.fixture:setCategory(ctx.categories.oneWayPlatform)
    else
      obstacle.fixture:setCategory(ctx.categories.ground)
    end
  end)
end

function Map:draw()
  local g = love.graphics

  g.setColor(255, 255, 255)
  local image = data.media.graphics.dinoland.dinolandBackground1
  local scale = self.height / image:getHeight()
  for x = 1, self.width, image:getWidth() * scale * 2 do
    image = data.media.graphics.dinoland.dinolandBackground1
    g.draw(image, x, self.height, 0, scale, scale, 0, image:getHeight())
    image = data.media.graphics.dinoland.dinolandBackground2
    g.draw(image, x + image:getWidth() * scale, self.height, 0, scale, scale, 0, image:getHeight())
  end

  g.setColor(136, 87, 44)
  physics.draw('fill', self.ground)

  table.each(self.obstacles, function(obstacle)
    physics.draw('fill', obstacle)
  end)
end

function Map:getMaxX()
  for i = 1, #self.zones do
    if self.zones[i].active then
      return self.zones[i].x
    end
  end

  return self.width
end
