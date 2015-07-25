Person = extend(Enemy)

----------------
-- Core
----------------
function Person:activate()
  local widthRatio = self.image:getWidth() / self.image:getHeight()
  self.h = 45
  self.w = self.h * widthRatio
  self.scale = self.h / self.image:getHeight()

  self.body = love.physics.newBody(ctx.world, self.x - self.w / 2, self.y - self.h / 2, 'dynamic')
  self.shape = love.physics.newRectangleShape(self.w, self.h)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.body:setUserData(self)
  self.body:setFixedRotation(true)

  self.fixture:setFriction(.75)
  self.fixture:setCategory(ctx.categories.person)
  self.fixture:setMask(ctx.categories.person, ctx.categories.building, ctx.categories.debris)

  self.phlerp = PhysicsInterpolator(self.body)

  ctx.event:emit('view.register', {object = self})

  Enemy.activate(self)
end

function Person:update()
  self.phlerp:update()

  if self.state then
    self.state.update(self)
  end
end

function Person:draw()
  local g = love.graphics

  self.phlerp:lerp()

  local x, y, angle = self.body:getX(), self.body:getY(), self.body:getAngle()
  g.setColor(255, 255, 255)
  g.draw(self.image, x, y, angle, self.scale * self.direction, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

  self.phlerp:delerp()
end

----------------
-- Helpers
----------------
function Person:hop(direction)
  self.body:applyLinearImpulse(60 * direction, -90)
end

function Person:directionTo(object)
  return lume.sign(object.body:getX() - self.body:getX())
end

function Person:distanceTo(object)
  return math.abs(object.body:getX() - self.body:getX())
end

function Person:changeState(target)
  if self.state == target then return end
  f.exe(self.state.exit, self)
  self.state = self[target]
  f.exe(self.state.enter, self)
  return self.state
end

----------------
-- Base States
----------------
Person.dead = {}
function Person.dead:enter()
  self.body:setFixedRotation(false)
  self.fixture:setCategory(ctx.categories.debris)
  self.fixture:setFriction(0.25)
  self.body:applyLinearImpulse(-200 + love.math.random() * 400, -300 + love.math.random() * -500)
  self.body:setAngularVelocity(-20 + love.math.random() * 40)
end

function Person.dead:update()
  local x, y = self.body:getLinearVelocity()
  if (math.abs(x) < 1 and math.abs(y) < 1) or (math.abs(x) > 5000 and math.abs(y) > 5000) then
    ctx.enemies:remove(self)
    self.body:destroy()
    ctx.event:emit('view.unregister', {object = self})
  end
end
