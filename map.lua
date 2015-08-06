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
    if (love.keyboard.isDown('down') and ctx.pigeon.downDirty > 0) or ctx.pigeon.body:getY() + ctx.pigeon.shapeSize / 2 > obstacle.body:getY() - obstacle.height / 2 then
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
    local padding = 5
    local x1, x2 = x - obstacle.width / 2 - padding, x + obstacle.width / 2 + padding
    local image = data.media.graphics[ctx.map.name].grassLeft
    local scale = 32 / image:getHeight()
    local xx = x1 + image:getWidth() * scale
    g.setColor(255, 255, 255)
    while xx < x2 do
      local image = data.media.graphics[ctx.map.name]['grassMid' .. love.math.random(1, 2)]
      g.draw(image, math.min(xx, x2 - image:getWidth() * scale * 2), y - obstacle.height / 2 - padding, 0, scale, scale)
      xx = xx + image:getWidth() * scale
    end
    local image = data.media.graphics[ctx.map.name].grassLeft
    local scale = 32 / image:getHeight()
    g.setColor(255, 255, 255)
    g.draw(image, x1, y - obstacle.height / 2 - padding, 0, scale, scale)
    local image = data.media.graphics[ctx.map.name].grassRight
    g.draw(image, x2, y - obstacle.height / 2 - padding, 0, scale, scale, image:getWidth())
  end

  -- Fake yellow sky
  g.setColor(254, 255, 113)
  g.rectangle('fill', 0, 0, self.width, self.height)

  g.setColor(255, 255, 255)
  local image = data.media.graphics.dinoland.background.sky
  local scale = (600) / image:getHeight()
  g.draw(image, ctx.view.x, self.height, 0, scale, scale, 0, image:getHeight())

  local inc = image:getWidth() * scale
  for n = 4, 1, -1 do
    for x = -500, self.width, inc * 2 do
      image = data.media.graphics[ctx.map.name].background.left
      g.draw(image, x + ctx.pigeon.body:getX() / 2, self.height, 0, scale, scale, 0, image:getHeight())
      image = data.media.graphics[ctx.map.name].background.right
      g.draw(image, x + inc + ctx.pigeon.body:getX() / 2, self.height, 0, scale, scale, 0, image:getHeight())
    end
  end

  local groundColor
  if ctx.map.name == 'dinoland' then
    groundColor = {136, 87, 44}
  else
    groundColor = {136, 87, 44}
  end

  g.setColor(groundColor)
  physics.draw('fill', self.ground)

  love.math.setRandomSeed(1)
  drawGrass(self.ground)

  for i = 1, #self.obstacles do
    local obstacle = self.obstacles[i]
    love.math.setRandomSeed(obstacle.body:getX() + obstacle.width)
    g.setColor(groundColor)
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
