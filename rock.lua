Rock = class()

Rock.category = 5

function Rock:init(x, y)
  self.body = love.physics.newBody(ctx.world, x, y, 'dynamic')
  self.shape = love.physics.newCircleShape(10)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)

  self.fixture:setCategory(self.category)
  self.fixture:setMask(self.category, Building.category, Person.category)
  self.fixture:setGroupIndex(1)

  self.body:setMass(10)
  self.body:applyLinearImpulse(-2000, -5000)
  self.body:setFixedRotation(true)
  self.fixture:setFriction(.35)

  lume.push(ctx.projectiles, self)

  ctx.event:emit('view.register', {object = self})
end

function Rock:update()
  local x, y = self.body:getLinearVelocity()
  if (math.abs(x) < 1 and math.abs(y) < 1) or (math.abs(x) > 5000 and math.abs(y) > 5000) then
    lume.remove(ctx.projectiles, self)
    self.body:destroy()
    ctx.event:emit('view.unregister', {object = self})
  end
end

function Rock:draw()
  local g = love.graphics
  g.setColor(128, 128, 128)
  g.circle('fill', self.body:getX(), self.body:getY(), 10)
end
