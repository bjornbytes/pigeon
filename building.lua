Building = class()

Building.wallWidth = 16

function Building:activate()
  self.y = ctx.map.height - ctx.map.ground.height

  self.pieces = {}

  -- Roof
  local piece = {}
  piece.body = love.physics.newBody(ctx.world, self.x, self.y - self.height - self.wallWidth / 2, 'dynamic')
  piece.body:setUserData(self)
  piece.shape = love.physics.newRectangleShape(self.width, self.wallWidth)
  piece.fixture = love.physics.newFixture(piece.body, piece.shape)
  piece.fixture:setCategory(ctx.categories.building)
  piece.fixture:setMask(ctx.categories.debris)
  piece.phlerp = PhysicsInterpolator(piece.body)
  table.insert(self.pieces, piece)

  -- Left wall
  piece = {}
  piece.body = love.physics.newBody(ctx.world, self.x - self.width / 2 + self.wallWidth / 2, self.y - self.height / 2, 'dynamic')
  piece.body:setUserData(self)
  piece.shape = love.physics.newRectangleShape(self.wallWidth, self.height)
  piece.fixture = love.physics.newFixture(piece.body, piece.shape)
  piece.fixture:setCategory(ctx.categories.building)
  piece.fixture:setMask(ctx.categories.debris)
  piece.phlerp = PhysicsInterpolator(piece.body)
  table.insert(self.pieces, piece)

  -- Right wall
  piece = {}
  piece.body = love.physics.newBody(ctx.world, self.x + self.width / 2 - self.wallWidth / 2, self.y - self.height / 2, 'dynamic')
  piece.body:setUserData(self)
  piece.shape = love.physics.newRectangleShape(self.wallWidth, self.height)
  piece.fixture = love.physics.newFixture(piece.body, piece.shape)
  piece.fixture:setCategory(ctx.categories.building)
  piece.fixture:setMask(ctx.categories.debris)
  piece.phlerp = PhysicsInterpolator(piece.body)
  table.insert(self.pieces, piece)

  self.destroyed = false

  ctx.event:emit('view.register', {object = self})
end

function Building:update()
  table.each(self.pieces, function(piece)
    piece.phlerp:update()
  end)

  if ctx.pigeon.body:getY() + ctx.pigeon.shapeSize / 2 > self.pieces[1].body:getY() - self.wallWidth / 2 then
    --self.pieces[1].fixture:setCategory(ctx.categories.oneWayPlatform)
  else
    --self.pieces[1].fixture:setCategory(ctx.categories.building)
  end
end

function Building:draw()
  local g = love.graphics

  table.each(self.pieces, function(piece)
    piece.phlerp:lerp()
    local points = {piece.body:getWorldPoints(piece.shape:getPoints())}
    g.setColor(255, 255, 255)
    g.polygon('line', points)
    piece.phlerp:delerp()
  end)
end

function Building:collideWith(other)
  if isa(other, Building) then return true
  elseif isa(other, Pigeon) then self:destroy() end
end

function Building:destroy()
  if self.destroyed then return end

  self.destroyed = true

  table.each(self.pieces, function(piece)
    --piece.body:setType('dynamic')
    piece.body:applyAngularImpulse(lume.random(1000, 2000) * (love.math.random() > .5 and 1 or -1))
    piece.fixture:setCategory(ctx.categories.debris)
  end)
end
