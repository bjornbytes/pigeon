Map = class()

function Map:init()
  self.ground = {}
  self.ground.width = self.width
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

  local function drawGrass(obstacle)
    local x, y = obstacle.body:getPosition()
    local x1, x2 = x - obstacle.width / 2, x + obstacle.width / 2
    local image = data.media.graphics.dinoland.grassLeft
    local scale = 32 / image:getHeight()
    local xx = x1 + image:getWidth() * scale
    g.setColor(255, 255, 255)
    while xx < x2 do
      local image = data.media.graphics.dinoland['grassMid' .. love.math.random(1, 2)]
      g.draw(image, math.min(xx, x2 - image:getWidth() * scale * 2), y - obstacle.height / 2, 0, scale, scale)
      xx = xx + image:getWidth() * scale
    end
    local image = data.media.graphics.dinoland.grassLeft
    local scale = 32 / image:getHeight()
    g.setColor(255, 255, 255)
    g.draw(image, x1, y - obstacle.height / 2, 0, scale, scale)
    local image = data.media.graphics.dinoland.grassRight
    g.draw(image, x2, y - obstacle.height / 2, 0, scale, scale, image:getWidth())
  end

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

  love.math.setRandomSeed(1)
  drawGrass(self.ground)

  for i = 1, #self.obstacles do
    local obstacle = self.obstacles[i]
    love.math.setRandomSeed(obstacle.body:getX() + obstacle.width)
    g.setColor(136, 87, 44)
    physics.draw('fill', obstacle)

    drawGrass(obstacle)
  end
  love.math.setRandomSeed(love.timer.getTime())

  table.each(self.decorations, function(d)
    local scale = d.height / d.image:getHeight()
    g.setColor(255, 255, 255)
    g.draw(d.image, d.x, d.y, 0, scale * d.direction, scale, d.image:getWidth() / 2, d.image:getHeight())
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
